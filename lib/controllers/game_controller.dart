// game_provider.dart

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class GameController with ChangeNotifier {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String? winner;
  bool draw = false;
  List<int> winningIndices = [];

  final ConfettiController confettiController =
  ConfettiController(duration: const Duration(seconds: 2));

  void handleTap(int index) {
    if (board[index] != '' || winner != null) return;

    board[index] = currentPlayer;
    checkWinner();

    if (winner == null && !board.contains('')) {
      draw = true;
      notifyListeners();
    }

    if (winner == null) {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    }

    notifyListeners();
  }

  void checkWinner() {
    List<List<int>> combos = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combo in combos) {
      String a = board[combo[0]];
      String b = board[combo[1]];
      String c = board[combo[2]];
      if (a != '' && a == b && b == c) {
        winner = a;
        winningIndices = combo;
        confettiController.play();
        notifyListeners();
        return;
      }
    }
  }

  void resetGame() {
    board = List.filled(9, '');
    currentPlayer = 'X';
    winner = null;
    draw = false;
    winningIndices.clear();
    confettiController.stop();
    notifyListeners();
  }

  void disposeController() {
    confettiController.dispose();
  }
}
