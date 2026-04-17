import 'dart:async';
import 'dart:math';
import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';

class SwipeGameScreen extends StatefulWidget {
  const SwipeGameScreen({super.key});

  @override
  SwipeGameScreenState createState() => SwipeGameScreenState();
}

class SwipeGameScreenState extends State<SwipeGameScreen> {
  final List<String> directions = ['up', 'down', 'left', 'right'];
  String currentDirection = '';
  String wrongDirection = '';
  int score = 0;
  bool gameOver = false;
  bool showWrongDirection = false;
  Timer? gameTimer;
  int timeLimit = 2;
  bool timerActive = false;

  bool showModeSelection = true;
  bool isMultiplayer = false;
  String currentPlayer = 'A';
  int playerAScore = 0;
  int playerBScore = 0;
  bool playerAGameOver = false;
  bool playerBGameOver = false;

  @override
  void initState() {
    super.initState();
  }

  void _startGame({required bool multiplayer}) {
    setState(() {
      showModeSelection = false;
      isMultiplayer = multiplayer;
      currentPlayer = 'A';
      playerAScore = 0;
      playerBScore = 0;
      score = 0;
      gameOver = false;
      playerAGameOver = false;
      playerBGameOver = false;
    });
    _generateNewDirection();
  }

  void _generateNewDirection() {
    final random = Random();
    setState(() {
      currentDirection = directions[random.nextInt(4)];
      wrongDirection = directions[random.nextInt(4)];
      timerActive = true;
      showWrongDirection = false;
    });

    startCountdown(); // Start countdown timer
  }

  void _showPlayerBDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Player B\'s Turn',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentPlayer = 'B';
                score = 0;
                playerBGameOver = false;
              });
              _generateNewDirection(); // Start game for Player B
            },
            child: const Text('Tap to Start'),
          )
        ],
      ),
    );
  }

  void startCountdown() {
    timeLimit = 2;
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLimit > 0) {
        setState(() {
          timeLimit--;
        });
      } else {
        timer.cancel();
        _onTimeOut();
      }
    });
  }

  void _onTimeOut() {
    if (isMultiplayer) {
      _endCurrentPlayerGame();
    } else {
      setState(() {
        gameOver = true;
      });
    }
  }

  void _handleSwipe(String userSwipe) {
    if (gameOver || !timerActive) return;

    String expected = showWrongDirection ? wrongDirection : currentDirection;
    if (userSwipe == expected) {
      setState(() {
        score++;
        if (isMultiplayer) {
          if (currentPlayer == 'A') {
            playerAScore++;
          } else {
            playerBScore++;
          }
        }
      });
      _generateNewDirection();
    } else {
      if (isMultiplayer) {
        _endCurrentPlayerGame();
      } else {
        setState(() {
          gameOver = true;
        });
      }
    }
  }

  void _endCurrentPlayerGame() {
    gameTimer?.cancel();

    if (currentPlayer == 'A') {
      setState(() {
        playerAGameOver = true;
      });
      _showPlayerBDialog();
    } else {
      setState(() {
        playerBGameOver = true;
        gameOver = true;
      });
    }
  }

  void _restartGame() {
    setState(() {
      showModeSelection = true;
      score = 0;
      gameOver = false;
    });
    gameTimer?.cancel();
  }

  Icon _getArrowIcon() {
    switch (currentDirection) {
      case 'up':
        return const Icon(Icons.arrow_upward, size: 80);
      case 'down':
        return const Icon(Icons.arrow_downward, size: 80);
      case 'left':
        return const Icon(Icons.arrow_back, size: 80);
      case 'right':
        return const Icon(Icons.arrow_forward, size: 80);
      default:
        return const Icon(Icons.help_outline, size: 80);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy < 0) {
          _handleSwipe('up');
        } else {
          _handleSwipe('down');
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < 0) {
          _handleSwipe('left');
        } else {
          _handleSwipe('right');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: AppColors.alertColor,
          title: const Text(
            'Swipe Challenge',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: showModeSelection
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Choose Game Mode',
                        style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _startGame(multiplayer: false),
                      child: const Text('Single Player'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _startGame(multiplayer: true),
                      child: const Text('Multiplayer'),
                    ),
                  ],
                )
              : gameOver && isMultiplayer
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Multiplayer Results',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        Text('Player A Score: $playerAScore',
                            style: const TextStyle(fontSize: 22)),
                        Text('Player B Score: $playerBScore',
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _restartGame,
                          child: const Text('Play Again'),
                        ),
                      ],
                    )
                  : gameOver
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Game Over!',
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                            Text('Your Score: $score',
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _restartGame,
                              child: const Text('Play Again'),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isMultiplayer)
                              Text('Player $currentPlayer\'s Turn',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            Text('Score: $score',
                                style: const TextStyle(fontSize: 22)),
                            Text('Time Left: $timeLimit seconds',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 40),
                            const Text('Swipe this way:',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 20),
                            _getArrowIcon(),
                            const SizedBox(height: 20),
                            const Text('(Swipe on the screen)',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}
