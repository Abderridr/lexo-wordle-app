import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_logic.dart';

class Tile extends StatefulWidget {
  final String letter;
  final LetterColor color;
  final bool animate;
  final Duration delay;

  const Tile({
    Key? key,
    required this.letter,
    required this.color,
    this.animate = false,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final letter = widget.letter;
    final color = widget.color;
    final animate = widget.animate;

    Color bgColor = Colors.transparent;
    Color borderColor = const Color(0xFFD3D3D3); // Lighter border for light theme
    double borderGlow = 0.0;

    switch (color) {
      case LetterColor.correct:
        bgColor = const Color(0xFF22C55E);
        borderColor = bgColor;
        break;
      case LetterColor.present:
        bgColor = const Color(0xFFF59E0B);
        borderColor = bgColor;
        break;
      case LetterColor.absent:
        bgColor = const Color(0xFF787C7E); // Better color for absent in both themes
        borderColor = bgColor;
        break;
      case LetterColor.unknown:
        if (letter.isNotEmpty) {
          borderColor = const Color(0xFF565758); // Slightly brighter for active input
        }
        break;
    }

    Widget content = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(6),
        boxShadow: null,
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: GoogleFonts.spaceMono(
          color: (color == LetterColor.unknown) ? const Color(0xFF333333) : Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (animate) {
      if (color == LetterColor.unknown && letter.isNotEmpty) {
        // Pop animation when typing
        return content.animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 150.ms,
            curve: Curves.easeOut);
      } else if (color != LetterColor.unknown) {
        // Flip animation when verified
        return content
            .animate(delay: widget.delay)
            .flip(duration: 400.ms, curve: Curves.easeInOut, direction: Axis.horizontal);
      }
    }

    return content;
  }
}
