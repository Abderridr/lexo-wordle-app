import 'package:flutter/material.dart';
import '../game/game_logic.dart';

class StatsScreen extends StatelessWidget {
  final GameLogic game;

  const StatsScreen({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int winPercent = game.gamesPlayed > 0 
        ? ((game.gamesWon / game.gamesPlayed) * 100).round() 
        : 0;

    return Container(
      padding: const EdgeInsets.all(24.0),
      color: const Color(0xFFF2F0EF),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Statistics",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatBox(game.gamesPlayed.toString(), "Played"),
              _buildStatBox("$winPercent", "Win %"),
              _buildStatBox(game.currentStreak.toString(), "Current\nStreak"),
              _buildStatBox(game.maxStreak.toString(), "Max\nStreak"),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Guess Distribution",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 10),
          _buildDistribution(),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF538D4E),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDistribution() {
    int maxDist = 1;
    for (int d in game.guessDistribution) {
      if (d > maxDist) maxDist = d;
    }

    return Column(
      children: List.generate(6, (index) {
        int count = game.guessDistribution[index];
        bool isCurrent = game.isWinner && game.guesses.length - 1 == index;
        double widthFactor = count / maxDist;
        if (widthFactor < 0.05 && count > 0) widthFactor = 0.05;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Text("${index + 1}", style: const TextStyle(color: Color(0xFF333333))),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: count > 0 ? widthFactor : null,
                    child: Container(
                      height: 24,
                      width: count == 0 ? 24 : null, // min width if count 0
                      color: isCurrent ? const Color(0xFF538D4E) : const Color(0xFFB0BEC5),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
