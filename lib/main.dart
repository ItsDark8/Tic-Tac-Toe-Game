import 'package:confetti/confetti.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/game_controller.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => GameController(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData.dark(),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<GameController>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.winner != null || provider.draw) {
        _showResultDialog(provider.winner, provider.draw);
      }
    });
  }

  void _showResultDialog(String? winner, bool draw) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          draw ? "It's a Draw!" : "🎉 Victory!",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          draw
              ? "Neither player won. Try again!"
              : "Player '$winner' wins the game!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<GameController>(context, listen: false).resetGame();
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Provider.of<GameController>(context, listen: false).disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.winner != null
                    ? '${provider.winner} Wins!'
                    : provider.draw
                    ? 'Draw!'
                    : 'Current Player: ${provider.currentPlayer}',
                style: const TextStyle(fontSize: 24),
              ),

              const SizedBox(height: 20),

              GridView.builder(
                shrinkWrap: true,
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) {
                  final value = provider.board[index];
                  final isWinnerCell = provider.winningIndices.contains(index);

                  return GestureDetector(
                    onTap: () => provider.handleTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        color: isWinnerCell ? Colors.green.shade800 : Colors.black,
                      ),
                      child: Center(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: isWinnerCell ? Colors.yellowAccent : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: provider.resetGame,
                child: const Text('Restart'),
              ),
            ],
          ),

          // Confetti overlay 🎉
          ConfettiWidget(
            confettiController: provider.confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.08,
            numberOfParticles: 25,
            gravity: 0.3,
          ),
        ],
      ),
    );
  }
}


