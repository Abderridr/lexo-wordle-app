import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/game_logic.dart';

class EnglishKeyboard extends StatelessWidget {
  final GameLogic game;
  final VoidCallback onBackspace;
  final VoidCallback onConfirm;
  final Function(String) onKeyTap;

  const EnglishKeyboard({
    Key? key,
    required this.game,
    required this.onBackspace,
    required this.onConfirm,
    required this.onKeyTap,
  }) : super(key: key);

  static const List<List<String>> keys = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M']
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(keys[0]),
        _buildRow(keys[1]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton("ENTER", () {
              onConfirm();
            }, flex: 2),
            ...keys[2].map(
              (letter) => _buildKey(letter)
            ).toList(),
            _buildActionButton("⌫", () {
              onBackspace();
            }, flex: 2),
          ],
        )
      ],
    );
  }

  Widget _buildRow(List<String> rowKeys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowKeys.map(
        (letter) => _buildKey(letter)
      ).toList(),
    );
  }

  Widget _buildKey(String letter) {
    LetterColor state = game.letterStates[letter] ?? LetterColor.unknown;
    
    Color bgColor = const Color(0xFFD1D5DB); // Light gray for light theme
    Color fgColor = const Color(0xFF333333);

    switch (state) {
      case LetterColor.correct:
        bgColor = const Color(0xFF22C55E);
        break;
      case LetterColor.present:
        bgColor = const Color(0xFFF59E0B);
        break;
      case LetterColor.absent:
        bgColor = const Color(0xFF787C7E);
        fgColor = Colors.white;
        break;
      default:
        break;
    }

    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 3.0),
        child: _KeyboardKey(
          label: letter,
          bgColor: bgColor,
          textColor: fgColor,
          onTap: () {
            onKeyTap(letter);
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 3.0),
        child: _KeyboardKey(
          label: label,
          bgColor: const Color(0xFFD1D5DB), // Light gray backdrop
          textColor: const Color(0xFF333333),
          onTap: onTap,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _KeyboardKey extends StatefulWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;
  final double fontSize;

  const _KeyboardKey({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
    this.fontSize = 16,
  });

  @override
  State<_KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<_KeyboardKey> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.15).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        ),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.bgColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.textColor,
              fontWeight: FontWeight.bold,
              fontSize: widget.fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
