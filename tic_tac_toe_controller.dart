import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameState {
  final bool oTurn;
  final List<String> displayXO;
  final List<int> matchedIndexes;
  final int oScore;
  final int xScore;
  final int filledBoxes;
  final String resultDeclaration;
  final int seconds;
  final bool winnerFound;
  final bool isGameActive; // Added this field to manage game activation state

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
    required this.isGameActive, // Added this to track whether the game is active
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
    bool? isGameActive, // Added this to allow updating isGameActive
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
      isGameActive: isGameActive ?? this.isGameActive, // Ensure it gets updated
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
          isGameActive: false, // Initial state is inactive
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
      isGameActive: true, // Set game as active
    );
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.seconds > 0) {
        state = state.copyWith(seconds: state.seconds - 1);
      } else {
        stopTimer();
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
    // Ensure the move only happens if the game is active and the cell is empty
    if (state.isGameActive && state.seconds > 0 && state.displayXO[index] == '') {
      state = state.copyWith(
        displayXO: List.from(state.displayXO)
          ..[index] = state.oTurn ? 'O' : 'X',
        filledBoxes: state.filledBoxes + 1,
        oTurn: !state.oTurn,
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
      [0, 4, 8],
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
          isGameActive: false, // Set the game as inactive once we have a winner
        );
        stopTimer();
        return;
      }
    }

    if (state.filledBoxes == 9) {
      state = state.copyWith(
        resultDeclaration: 'It\'s a Draw!',
        winnerFound: true,
        isGameActive: false, // Set the game as inactive in case of a draw
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
