import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digifun/utilites/colors.dart';

final gameControllerProvider =
    StateNotifierProvider.autoDispose<GameController, GameState>((ref) {
  return GameController();
});
class GameState {
  final bool oTurn; // true if it's O's turn, false if it's X's turn
  final List<String> displayXO;
  final List<int> matchedIndexes;
  final int oScore;
  final int xScore;
  final int filledBoxes;
  final String resultDeclaration;
  final int seconds;
  final bool winnerFound;
  final bool isGameActive;

  GameState({
    required this.oTurn,
    required this.displayXO,
    required this.matchedIndexes,
    required this.oScore,
    required this.xScore,
    required this.filledBoxes,
    required this.resultDeclaration,
    required this.seconds,
    required this.winnerFound,
    required this.isGameActive,
  });

  GameState copyWith({
    bool? oTurn,
    List<String>? displayXO,
    List<int>? matchedIndexes,
    int? oScore,
    int? xScore,
    int? filledBoxes,
    String? resultDeclaration,
    int? seconds,
    bool? winnerFound,
    bool? isGameActive,
  }) {
    return GameState(
      oTurn: oTurn ?? this.oTurn,
      displayXO: displayXO ?? this.displayXO,
      matchedIndexes: matchedIndexes ?? this.matchedIndexes,
      oScore: oScore ?? this.oScore,
      xScore: xScore ?? this.xScore,
      filledBoxes: filledBoxes ?? this.filledBoxes,
      resultDeclaration: resultDeclaration ?? this.resultDeclaration,
      seconds: seconds ?? this.seconds,
      winnerFound: winnerFound ?? this.winnerFound,
      isGameActive: isGameActive ?? this.isGameActive,
    );
  }
}

class GameController extends StateNotifier<GameState> {
  GameController()
      : super(GameState(
          oTurn: true,
          displayXO: List.filled(9, ''),
          matchedIndexes: [],
          oScore: 0,
          xScore: 0,
          filledBoxes: 0,
          resultDeclaration: '',
          seconds: 30,
          winnerFound: false,
          isGameActive: false,
        ));

  Timer? timer;

  void startGame() {
    state = state.copyWith(
      oTurn: true,
      displayXO: List.filled(9, ''),
      matchedIndexes: [],
      resultDeclaration: '',
      filledBoxes: 0,
      winnerFound: false,
      seconds: 30,
      isGameActive: true,
    );
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.seconds > 0) {
        state = state.copyWith(seconds: state.seconds - 1);
      } else {
        stopTimer();
        // Handle game over when time runs out
        state = state.copyWith(
          resultDeclaration: 'Time Over!',
          winnerFound: true,
          isGameActive: false,
        );
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    resetTimer();
  }

  void resetTimer() {
    state = state.copyWith(seconds: 30);
  }

  void tapped(int index) {
    if (state.isGameActive && state.seconds > 0 && state.displayXO[index] == '') {
      state = state.copyWith(
        displayXO: List.from(state.displayXO)
          ..[index] = state.oTurn ? 'O' : 'X',
        filledBoxes: state.filledBoxes + 1,
        oTurn: !state.oTurn, // Switch turns
      );
      _checkWinner();
    }
  }

  void _checkWinner() {
    const winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0 , 4, 8],
      [2, 4, 6],
    ];

    for (var combo in winningCombinations) {
      if (state.displayXO[combo[0]] != '' &&
          state.displayXO[combo[0]] == state.displayXO[combo[1]] &&
          state.displayXO[combo[1]] == state.displayXO[combo[2]]) {
        String winner = state.displayXO[combo[0]];
        _updateScore(winner);
        state = state.copyWith(
          resultDeclaration: '$winner Wins!',
          winnerFound: true,
          isGameActive: false,
        );
        stopTimer();
        return;
      }
    }

    if (state.filledBoxes == 9) {
      state = state.copyWith(
        resultDeclaration: 'It\'s a Draw!',
        winnerFound: true,
        isGameActive: false,
      );
      stopTimer();
    }
  }

  void _updateScore(String winner) {
    if (winner == 'O') {
      state = state.copyWith(oScore: state.oScore + 1);
    } else if (winner == 'X') {
      state = state.copyWith(xScore: state.xScore + 1);
    }
  }
}

class TicTacToeScreen extends ConsumerWidget {
  const TicTacToeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Tic Tac Toe',
          style: TextStyle(
            fontFamily: "Pacifico",
            color: AppColors.textPrimaryColor,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildScoreboard(gameState),
            const SizedBox(height: 20),
            Expanded(
              child: _buildGameGrid(gameState, controller),
            ),
            _buildGameControls(gameState, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboard(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPlayerScore('Player O', gameState.oScore, gameState.oTurn),
          _buildTimerIndicator(gameState),
          _buildPlayerScore('Player X', gameState.xScore, !gameState.oTurn),
        ],
      ),
    );
  }

  Widget _buildPlayerScore(String player, int score, bool isActive) {
    return Column(
      children: [
        Text(
          player,
          style: GoogleFonts.coiny(
            textStyle: TextStyle(
              color: isActive ? AppColors.accentColor : Colors.grey,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
        ),
        Text(
          score.toString(),
          style: GoogleFonts.coiny(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerIndicator(GameState gameState) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (gameState.seconds > 0 && gameState.isGameActive)
            CircularProgressIndicator(
              value: 1 - gameState.seconds / 30,
              valueColor: const AlwaysStoppedAnimation(Colors.black),
              strokeWidth: 6,
            ),
          Center(
            child: Text(
              gameState.isGameActive ? gameState.seconds.toString() : '',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid(GameState gameState, GameController controller) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final isWinningCell = gameState.matchedIndexes.contains(index);
        return GestureDetector(
          onTap: gameState.isGameActive ? () => controller.tapped(index) : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isWinningCell ? AppColors.accentColor : AppColors.yellowColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                gameState.displayXO[index],
                style: GoogleFonts.coiny(
                  textStyle: TextStyle(
                    fontSize: 64,
                    color: isWinningCell
                        ? AppColors.yellowColor
                        : AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameControls(GameState gameState, GameController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text(
            gameState.resultDeclaration,
            style: GoogleFonts.coiny(
              fontSize: 24,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (gameState.winnerFound || gameState.filledBoxes == 9 || !gameState.isGameActive)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whiteColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => controller.startGame(),
              child: Text(
                gameState.isGameActive ? 'Restart Game' : 'Start Game',
                style: GoogleFonts.coiny(
                  textStyle: const TextStyle(fontSize: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}