import 'dart:async';
import 'dart:math';
import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';

class OddOneOutGame extends StatefulWidget {
  const OddOneOutGame({super.key});

  @override
  State<OddOneOutGame> createState() => _OddOneOutGameState();
}

class _OddOneOutGameState extends State<OddOneOutGame> {
  final List<String> emojis = [
    '😊',
    '😍',
    '😎',
    '😜',
    '🥳',
    '😂',
    '😃',
    '😈',
    '🤩',
    '😆',
    '🥺',
    '😛',
    '😋',
    '🤔',
    '🙄',
    '😏',
    '😇',
    '😝',
    '🤗',
    '😶'
  ];

  int score = 0;
  int player1Score = 0;
  int player2Score = 0;

  int timeLeft = 10;
  Timer? timer;
  bool isPlaying = false;
  bool isMultiplayer = false;
  String currentPlayer = "Player 1";

  late int count;
  late int oddIndex;
  late String commonEmoji;
  late String oddEmoji;

  @override
  void initState() {
    super.initState();
  }

  void startGame({bool multiplayer = false}) {
    setState(() {
      score = 0;
      timeLeft = 10;
      isPlaying = true;
      isMultiplayer = multiplayer;
      currentPlayer = "Player 1";
    });
    _setupRound();
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft == 0) {
        t.cancel();
        _gameOver('Time\'s up! Game Over!');
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  void _gameOver(String message) {
    isPlaying = false;

    if (isMultiplayer) {
      if (currentPlayer == "Player 1") {
        player1Score = score;
        _showPlayerBDialog();
      } else {
        player2Score = score;
        _showMultiplayerResult();
      }
    } else {
      _showMessage(message);
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(
          '$message\nYour Score: $score',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                isPlaying = false;
                score = 0;
                timeLeft = 10;
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showPlayerBDialog() {
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
              Navigator.of(context).pop();
              setState(() {
                currentPlayer = "Player 2";
                score = 0;
                timeLeft = 10;
                isPlaying = true;
              });
              _setupRound();
              _startTimer();
            },
            child: const Text('Tap to Start'),
          )
        ],
      ),
    );
  }

  void _showMultiplayerResult() {
    String result;
    if (player1Score > player2Score) {
      result = 'Player 1 Wins!';
    } else if (player2Score > player1Score) {
      result = 'Player 2 Wins!';
    } else {
      result = 'It\'s a Draw!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Multiplayer Result'),
        content: Text(
          'Player 1 Score: $player1Score\nPlayer 2 Score: $player2Score\n\n$result',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                isPlaying = false;
                score = 0;
                timeLeft = 10;
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _setupRound() {
    final random = Random();
    count = 15 + random.nextInt(3);
    commonEmoji = emojis[random.nextInt(emojis.length)];
    do {
      oddEmoji = emojis[random.nextInt(emojis.length)];
    } while (oddEmoji == commonEmoji);
    oddIndex = random.nextInt(count);

    setState(() {
      timeLeft = 5;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _onEmojiTap(int index) {
    if (!isPlaying) return;

    final bool isOdd = (index == oddIndex);
    if (isOdd) {
      setState(() {
        score++;
      });
      _setupRound();
    } else {
      timer?.cancel();
      _gameOver('Oops! That was not the odd one out.');
    }
  }

  Widget _buildEmojiGrid() {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.alertColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: List.generate(count, (index) {
            String emojiToShow = (index == oddIndex) ? oddEmoji : commonEmoji;
            return GestureDetector(
              onTap: () => _onEmojiTap(index),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  emojiToShow,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTurnMessage() {
    return Text(
      '$currentPlayer\'s Turn',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Odd One Out',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              'Time left: $timeLeft s',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (isMultiplayer) _buildTurnMessage(),
            const SizedBox(height: 30),
            if (!isPlaying)
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => startGame(multiplayer: false),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text('Start Single Player',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => startGame(multiplayer: true),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text('Start Multiplayer',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(child: _buildEmojiGrid()),
          ],
        ),
      ),
    );
  }
}
