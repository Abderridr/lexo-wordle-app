import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/game_logic.dart';
import 'tile.dart';

class GameGrid extends StatelessWidget {
  final GameLogic game;
  const GameGrid({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(GameLogic.maxAttempts, (rowIndex) {
        bool isCurrentRow = rowIndex == game.guesses.length;
        bool isSubmittedRow = rowIndex < game.guesses.length;
        
        String word = "";
        List<LetterColor> colors = List.filled(GameLogic.wordLength, LetterColor.unknown);
        
        if (isSubmittedRow) {
          word = game.guesses[rowIndex];
          colors = game.evaluateGuessColors(word);
        } else if (isCurrentRow) {
          word = game.currentGuess;
        }

        // Pad word to 5 letters
        word = word.padRight(GameLogic.wordLength, ' ');

        Widget rowWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(GameLogic.wordLength, (colIndex) {
            // Because Arabic is RTL, standard standard representation puts first typed char at right visually
            // Flutter Row handles RTL automatically if TextDirection is RTL, so colIndex 0 is right.
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Tile(
                letter: word[colIndex] == ' ' ? '' : word[colIndex],
                color: colors[colIndex],
                animate: isSubmittedRow,
                delay: Duration(milliseconds: colIndex * 80), // Staggered flip
              ),
            );
          }),
        );

        if (isCurrentRow && game.invalidWordMessage.isNotEmpty) {
          // Shake row
          rowWidget = rowWidget.animate()
              .shake(hz: 8, duration: 300.ms, curve: Curves.easeInOut);
        }

        return rowWidget;
      }),
    );
  }
}
