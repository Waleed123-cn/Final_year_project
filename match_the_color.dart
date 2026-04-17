import 'dart:async';
import 'dart:math';
import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  // Game colors configuration
  final List<String> easyColors = ['RED', 'GREEN', 'BLUE', 'YELLOW'];
  final List<String> mediumColors = ['PURPLE', 'ORANGE'];
  final List<String> hardColors = ['PINK', 'BROWN'];

  final Map<String, Color> colorMap = {
    'RED': Colors.red,
    'GREEN': Colors.green,
    'BLUE': Colors.blue,
    'YELLOW': Colors.yellow,
    'PURPLE': Colors.purple,
    'ORANGE': Colors.orange,
    'PINK': Colors.pink,
    'BROWN': Colors.brown,
  };

  // Game state
  late List<String> currentColors;
  late String correctColorName;
  late Color displayedColor;
  int score = 0;
  int timeLeft = 3;
  Timer? timer;
  bool gameOver = false;
  bool gameStarted = false;

  // Multiplayer mode
  bool isMultiplayer = false;
  bool isPlayerATurn = true;
  int playerAScore = 0;
  int playerBScore = 0;
  String winner = '';
  bool showModeSelection = true;

  @override
  void initState() {
    super.initState();
    currentColors = [...easyColors];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showModeSelection) {
        _showModeSelection();
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
                setState(() {
                  isMultiplayer = false;
                  showModeSelection = false;
                });
                _showInstructions();
              },
              child: const Text('Single Player'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isMultiplayer = true;
                  showModeSelection = false;
                });
                _showInstructions();
              },
              child: const Text('Multiplayer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎮 Welcome to Color Match Game!\n\n'
                '🟢 Match the TEXT, not the color!\n\n'
                '✅ Tap the button that matches the name of the color written.\n'
                '⏱ You only have 3 seconds to choose!\n\n'
                '📈 Levels:\n'
                '• Easy (0-4 correct answers)\n'
                '• Medium (5-9 correct answers)\n'
                '• Hard (10-14 correct answers)\n\n'
                '🏁 Game ends after 15 correct answers.',
                style: TextStyle(fontSize: 16),
              ),
              if (isMultiplayer) const SizedBox(height: 10),
              if (isMultiplayer)
                const Text(
                  '\n👥 Multiplayer Mode:\n'
                  '• Players take turns\n'
                  '• Player with highest score wins',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }

  void _startNewRound() {
    setState(() {
      gameOver = false;
      timeLeft = 3;
    });

    // Add more colors based on score
    if (score == 5) {
      currentColors.addAll(mediumColors);
      _showSnackBar('🎯 Medium Level Started!');
    } else if (score == 10) {
      currentColors.addAll(hardColors);
      _showSnackBar('🔥 Hard Level Started!');
    } else if (score == 15) {
      setState(() {
        gameOver = true;
        if (isMultiplayer) {
          if (playerAScore > playerBScore) {
            winner = 'Player A wins!';
          } else if (playerBScore > playerAScore) {
            winner = 'Player B wins!';
          } else {
            winner = 'It\'s a tie!';
          }
        }
      });
      return;
    }

    final rand = Random();
    correctColorName = currentColors[rand.nextInt(currentColors.length)];
    displayedColor =
        colorMap[currentColors[rand.nextInt(currentColors.length)]]!;

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        timeLeft--;
        if (timeLeft == 0) {
          t.cancel();
          if (isMultiplayer) {
            if (isPlayerATurn) {
              // Player A's time is up, switch to Player B
              isPlayerATurn = false;
              _showSnackBar('Time is up! Player B\'s turn.');
              _startNewRound(); // Start new round for Player B
            } else {
              // Player B's time is up, end the game
              setState(() {
                gameOver = true; // Set game over state
                // Determine winner
                if (playerAScore > playerBScore) {
                  winner = 'Player A wins!';
                } else if (playerBScore > playerAScore) {
                  winner = 'Player B wins!';
                } else {
                  winner = 'It\'s a tie!';
                }
              });
              _showSnackBar('Time is up! Game Over.');
            }
          } else {
            gameOver = true; // End game for single player
          }
        }
      });
    });
  }

  void _handleTap(String tappedColor) {
    if (gameOver) return;
    timer?.cancel();
    if (tappedColor == correctColorName) {
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
      _startNewRound();
    } else {
      setState(() {
        gameOver = true;
        if (isMultiplayer) {
          if (isPlayerATurn) {
            // Player A's turn ended, show dialog
            _showPlayerATurnOverDialog();
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
    }
  }

  void _showPlayerATurnOverDialog() {
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
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isPlayerATurn = false;
                gameOver = false;
              });
              _startNewRound();
            },
            child: const Text('Tap to Start'),
          )
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      score = 0;
      gameOver = false;
      currentColors = [...easyColors];
      gameStarted = true;
      playerAScore = 0;
      playerBScore = 0;
      isPlayerATurn = true;
      winner = '';
    });
    _startNewRound();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
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
            Text(winner,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ] else ...[
            const Text('Game Over!', style: TextStyle(fontSize: 28)),
            Text('Score: $score', style: const TextStyle(fontSize: 22)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            child: const Text('Play Again'),
          )
        ],
      ),
    );
  }

  Widget _buildInstructionsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to Color Match Game!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tap the button that matches the name of the color written.\n'
            'You have 3 seconds to choose!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isMultiplayer) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
          ),
          Text(
            isPlayerATurn ? 'Player A\'s turn' : 'Player B\'s turn',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
        ],
        const Text(
          'What is the TEXT (not the color)?',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        Text(
          correctColorName,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: displayedColor,
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Wrap(
            runSpacing: 15,
            spacing: 15,
            children: currentColors.map((color) {
              return ElevatedButton(
                onPressed: () => _handleTap(color),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorMap[color],
                  minimumSize: const Size(80, 80),
                  shape: const CircleBorder(),
                ),
                child: const SizedBox(),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 30),
        Text('Current Score: $score', style: const TextStyle(fontSize: 20)),
        Text('Time left: $timeLeft s', style: const TextStyle(fontSize: 20)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Color Match Tap',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: !gameStarted
          ? _buildInstructionsScreen()
          : gameOver && (!isMultiplayer || winner.isNotEmpty)
              ? _buildGameOverScreen()
              : _buildGameScreen(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
