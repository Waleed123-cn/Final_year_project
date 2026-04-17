import 'dart:async';
import 'dart:math';

import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';

class TapCircleGame extends StatefulWidget {
  const TapCircleGame({super.key});

  @override
  State<TapCircleGame> createState() => _TapCircleGameState();
}

class _TapCircleGameState extends State<TapCircleGame> {
  // Game state
  int score = 0;
  double top = 100;
  double left = 100;
  late Timer circleTimer;
  bool gameOver = false;
  bool _gameStarted = false;

  // Multiplayer mode
  bool isMultiplayer = false;
  bool isPlayerATurn = true;
  int playerAScore = 0;
  int playerBScore = 0;
  String winner = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_gameStarted) {
        _showModeSelection();
        _gameStarted = true;
      }
    });
  }

  void _showModeSelection() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Select Game Mode',
          style: TextStyle(
            color: AppColors.textPrimaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startGame(false);
              },
              child: const Text('Single Player'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startGame(true);
              },
              child: const Text('Multiplayer'),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(bool multiplayer) {
    setState(() {
      isMultiplayer = multiplayer;
      score = 0;
      gameOver = false;
      playerAScore = 0;
      playerBScore = 0;
      isPlayerATurn = true;
      winner = '';
      _showNewCircle();
    });
  }

  void _showNewCircle() {
    final random = Random();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    const double topMargin = 120; // to avoid score area
    const double circleSize = 70;

    top = topMargin +
        random.nextDouble() * (screenHeight - topMargin - circleSize - 50);
    left = random.nextDouble() * (screenWidth - circleSize - 20);

    circleTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        gameOver = true;
        if (isMultiplayer) {
          if (isPlayerATurn) {
            // Player A's turn ended, now Player B's turn
            isPlayerATurn = false;
            gameOver = false;
            score = 0;
            // Show 'Tap to Start' for Player B
            _showTapToStartForPlayerB();
          } else {
            // Both players have played, determine winner
            if (playerAScore > playerBScore) {
              winner = 'Player A wins!';
            } else if (playerBScore > playerAScore) {
              winner = 'Player B wins!';
            } else {
              winner = 'It\'s a tie!';
            }
          }
        }
      });
    });

    setState(() {});
  }

  void _handleTap() {
    if (!gameOver) {
      circleTimer.cancel();
      setState(() {
        score++;
        if (isMultiplayer) {
          if (isPlayerATurn) {
            playerAScore = score;
          } else {
            playerBScore = score;
          }
        }
      });
      _showNewCircle();
    }
  }

  // Add this function to show the "Tap to Start" screen for Player B
  void _showTapToStartForPlayerB() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Player B\'s Turn',
          style: TextStyle(
            color: AppColors.textPrimaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Start Player B's turn
                setState(() {
                  gameOver = false;
                  score = 0;
                  _showNewCircle();
                });
              },
              child: const Text('Tap to Start'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isMultiplayer) ...[
            Text('Player A Score: $playerAScore',
                style: const TextStyle(fontSize: 24)),
            Text('Player B Score: $playerBScore',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
          ],
          Text(
            isMultiplayer ? winner : 'Game Over!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            isMultiplayer ? '' : 'Score: $score',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _showModeSelection();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Stack(
      children: [
        Positioned(
          top: top,
          left: left,
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMultiplayer) ...[
                Text(
                  'Player A: $playerAScore',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        isPlayerATurn ? FontWeight.bold : FontWeight.normal,
                    color: isPlayerATurn ? Colors.blue : Colors.black,
                  ),
                ),
                Text(
                  'Player B: $playerBScore',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        !isPlayerATurn ? FontWeight.bold : FontWeight.normal,
                    color: !isPlayerATurn ? Colors.blue : Colors.black,
                  ),
                ),
              ],
              Text(
                'Current: $score',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isMultiplayer)
                Text(
                  isPlayerATurn ? 'Player A\'s turn' : 'Player B\'s turn',
                  style: const TextStyle(fontSize: 18),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Colors.red,
        title: const Text(
          "Tap the Circle",
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: gameOver && (!isMultiplayer || winner.isNotEmpty)
          ? _buildGameOverScreen()
          : _buildGameScreen(),
    );
  }

  @override
  void dispose() {
    if (circleTimer.isActive) {
      circleTimer.cancel();
    }
    super.dispose();
  }
}
