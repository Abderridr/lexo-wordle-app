import 'package:flutter/material.dart';
import '../widgets/tile.dart';
import '../game/game_logic.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: const Color(0xFFF2F0EF),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                "How to Play",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Guess the Wordle in 6 tries.\n\n"
              "Each guess must be a valid 5-letter word. Hit the enter button to submit.\n\n"
              "After each guess, the color of the tiles will change to show how close your guess was to the word.",
              style: TextStyle(color: Color(0xFF333333), fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text("Examples", style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            _buildExampleRow(['A', 'P', 'P', 'L', 'E'], 0, LetterColor.correct, "The letter A is in the word and in the correct spot."),
            const SizedBox(height: 10),
            _buildExampleRow(['S', 'M', 'I', 'L', 'E'], 2, LetterColor.present, "The letter I is in the word but in the wrong spot."),
            const SizedBox(height: 10),
            _buildExampleRow(['W', 'A', 'T', 'E', 'R'], 0, LetterColor.absent, "The letter W is not in the word in any spot."),
            const SizedBox(height: 30),
            const Text(
              "A new word is available each day!",
              style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleRow(List<String> letters, int highlightIndex, LetterColor highlightColor, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(letters.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Tile(
                  letter: letters[index],
                  color: index == highlightIndex ? highlightColor : LetterColor.unknown,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        )
      ],
    );
  }
}
