import 'dart:async';
import 'dart:math';
import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MathChallengeScreen extends ConsumerStatefulWidget {
  const MathChallengeScreen({super.key});

  @override
  MathChallengeScreenState createState() => MathChallengeScreenState();
}

class MathChallengeScreenState extends ConsumerState<MathChallengeScreen> {
  late String operation;
  late int num1, num2, correctAnswer;
  List<int> options = [];
  int playerAScore = 0;
  int playerBScore = 0;
  int questionCount = 0;
  int hintCount = 3;
  int level = 1;
  bool operationSelected = false;
  bool gameOver = false;
  bool isMultiplayer = false;
  bool isPlayerATurn = true;
  bool playerACompleted = false;
  bool playerBCompleted = false;

  final Map<String, String> opSymbols = {
    'add': '+',
    'subtract': '-',
    'multiply': '×',
    'divide': '÷',
  };

  @override
  void dispose() {
    super.dispose();
  }

  void _startGame(String op, {bool multiplayer = false}) {
    ref.read(timerProvider.notifier).stop();
    setState(() {
      operation = op;
      isMultiplayer = multiplayer;
      operationSelected = true;
      isPlayerATurn = true;
      playerACompleted = false;
      playerBCompleted = false;
      playerAScore = 0;
      playerBScore = 0;
      questionCount = 0;
      hintCount = 3;
      level = 1;
      gameOver = false;
    });
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    int min = 1, max = 20;

    num1 = random.nextInt(max - min + 1) + min;
    num2 = random.nextInt(max - min + 1) + min;

    switch (operation) {
      case 'add':
        correctAnswer = num1 + num2;
        break;
      case 'subtract':
        correctAnswer = num1 - num2;
        break;
      case 'multiply':
        correctAnswer = num1 * num2;
        break;
      case 'divide':
        num2 = random.nextInt(9) + 1;
        num1 = num2 * (random.nextInt(10) + 1);
        correctAnswer = (num1 / num2).round();
        break;
    }

    Set<int> optionSet = {correctAnswer};
    while (optionSet.length < 4) {
      int wrong = correctAnswer + random.nextInt(10) - 5;
      if (wrong != correctAnswer && wrong > 0) optionSet.add(wrong);
    }
    options = optionSet.toList()..shuffle();

    ref.read(timerProvider.notifier).start(_handleLoss);
  }

  void _checkAnswer(int selected) {
    if (selected == correctAnswer) {
      if (isPlayerATurn) {
        playerAScore++;
      } else {
        playerBScore++;
      }
      questionCount++;
      if (questionCount % 10 == 0 && level < 3) {
        level++;
        _showLevelSnackbar();
      }
      _generateQuestion();
    } else {
      _handleLoss();
    }
  }

  void _handleLoss() {
    if (!mounted) return;
    ref.read(timerProvider.notifier).stop();
    setState(() {
      if (isPlayerATurn) {
        playerACompleted = true;
        isPlayerATurn = false;
        if (isMultiplayer) {
          _showPlayerATurnOverDialog();
        } else {
          gameOver = true;
        }
      } else {
        playerBCompleted = true;
        gameOver = true;
      }
    });
  }

  void _showPlayerATurnOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.alertColor,
        title: const Text('Player B\'s Turn',
            style: TextStyle(color: AppColors.textPrimaryColor)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startPlayerB();
            },
            child: const Text('Tap to Start'),
          )
        ],
      ),
    );
  }

  void _startPlayerB() {
    if (!mounted) return;
    setState(() {
      questionCount = 0;
      hintCount = 3;
      level = 1;
      isPlayerATurn = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Player A's turn is over. Now it's Player B's turn!")),
      );
    });

    _generateQuestion();
  }

  void _useHint() {
    if (hintCount > 0) {
      setState(() {
        hintCount--;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hint: Correct answer is $correctAnswer')),
      );
    }
  }

  void _restartGame() {
    ref.read(timerProvider.notifier).stop();
    setState(() {
      operationSelected = false;
      gameOver = false;
      playerACompleted = false;
      playerBCompleted = false;
      isPlayerATurn = true;
    });
  }

  void _showLevelSnackbar() {
    String message = switch (level) {
      1 => 'Level 1: Easy questions!',
      2 => 'Level 2: Medium difficulty!',
      3 => 'Level 3: Hard questions!',
      _ => '',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showOperationSelector(bool multiplayer) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.alertColor,
        title: const Text('Choose Operation',
            style: TextStyle(color: AppColors.textPrimaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: opSymbols.keys
              .map((op) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startGame(op, multiplayer: multiplayer);
                      },
                      child: Text(opSymbols[op]!,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeLeft = ref.watch(timerProvider);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Math Challenge',
          style: TextStyle(
              fontFamily: 'Pacifico', fontSize: 24, color: Colors.white),
        ),
      ),
      body: !operationSelected
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Choose Mode:', style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _showOperationSelector(false),
                    child: const Text('Single Player'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _showOperationSelector(true),
                    child: const Text('Multiplayer'),
                  ),
                ],
              ),
            )
          : gameOver
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉 Game Over!',
                          style: TextStyle(fontSize: 28)),
                      if (isMultiplayer) ...[
                        Text('Player A Score: $playerAScore',
                            style: const TextStyle(fontSize: 22)),
                        Text('Player B Score: $playerBScore',
                            style: const TextStyle(fontSize: 22)),
                      ] else
                        Text('Score: $playerAScore',
                            style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: _restartGame,
                          child: const Text('Play Again')),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isMultiplayer
                            ? 'Turn: ${isPlayerATurn ? "Player A" : "Player B"}'
                            : 'Single Player Mode',
                        style: const TextStyle(fontSize: 25),
                      ),
                      Text('Level: $level | Question ${questionCount + 1}'),
                      Text('Time Left: $timeLeft sec',
                          style:
                              const TextStyle(color: Colors.red, fontSize: 22)),
                      const SizedBox(height: 20),
                      Text('$num1 ${opSymbols[operation]} $num2 = ?',
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 20),
                      ...options.map((opt) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: ElevatedButton(
                              onPressed: () => _checkAnswer(opt),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.alertColor,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: Text('$opt',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      color: AppColors.textPrimaryColor)),
                            ),
                          )),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.alertColor),
                        onPressed: hintCount > 0 ? _useHint : null,
                        child: Text('Hint ($hintCount left)',
                            style: const TextStyle(
                                color: AppColors.textPrimaryColor)),
                      ),
                      const SizedBox(height: 20),
                      Text(
                          'Score: ${isPlayerATurn ? playerAScore : playerBScore}',
                          style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
    );
  }
}

// Timer Provider

final timerProvider = StateNotifierProvider<TimerNotifier, int>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<int> {
  Timer? _timer;

  TimerNotifier() : super(10);

  void start(VoidCallback onTimeout) {
    _timer?.cancel();
    state = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state <= 1) {
        timer.cancel();
        onTimeout();
      } else {
        state--;
      }
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
