import 'package:flutter/material.dart';

import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_logic.dart';

import '../ads/ad_manager.dart';
import '../widgets/game_grid.dart';
import '../widgets/english_keyboard.dart';
import '../stats/stats_screen.dart';
import '../help/help_screen.dart';

class GameScreen extends StatefulWidget {
  final bool isFreePlay;
  const GameScreen({super.key, this.isFreePlay = false});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameLogic game;
  late ConfettiController _confettiController;
  final GlobalKey<State> _gridKey = GlobalKey<State>();
  
  // Custom shake controller
  double _shakeOffset = 0;

  @override
  void initState() {
    super.initState();
    game = GameLogic(isFreePlay: widget.isFreePlay);
    game.addListener(_onGameStateChanged);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    game.removeListener(_onGameStateChanged);
    _confettiController.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    setState(() {}); // Rebuild UI
  }

  void _showStats() {
    // Show stats in both modes now as requested
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatsScreen(game: game),
    );
  }

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const HelpScreen(),
    );
  }

  void _triggerShake() async {
    // Note: Audio and haptic feedback removed per user request
    
    // Quick shake animation loop
    for (int i = 0; i < 4; i++) {
      setState(() => _shakeOffset = 10);
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() => _shakeOffset = -10);
      await Future.delayed(const Duration(milliseconds: 50));
    }
    setState(() => _shakeOffset = 0);
  }

  void _handleInvalidWord() {
    _triggerShake();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(game.invalidWordMessage, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFFF4D6D),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 100, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleGameOver(bool isWin) async {
    if (isWin) {
      _confettiController.play();
    } else {
      // Lose sound removed
    }

    // Show interstitial ad on game over as per spec
    await Future.delayed(const Duration(milliseconds: 2000)); // wait for flips and sounds
    if (!widget.isFreePlay) {
      AdManager().showInterstitialAd();
    }

    

    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isWin ? const Color(0xFF22C55E) : const Color(0xFFFF4D6D),
              width: 3,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Icon(
                  isWin ? Icons.emoji_events_rounded : Icons.sentiment_very_dissatisfied_rounded,
                  size: 80,
                  color: isWin ? const Color(0xFF22C55E) : const Color(0xFFFF4D6D),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 16),
                
                // Result Text
                Text(
                  isWin ? "You Won!" : "Game Over",
                  style: GoogleFonts.pacifico(
                    fontSize: 32,
                    color: const Color(0xFF333333),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // The Word
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F0EF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "THE WORD WAS",
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.dailyWord.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF333333),
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Buttons Row
                Row(
                  children: [
                    // Home Button
                    Expanded(
                      child: _buildDialogButton(
                        label: "HOME",
                        icon: Icons.home_rounded,
                        color: const Color(0xFF787C7E),
                        onTap: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Return home
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Retry Button
                    Expanded(
                      child: _buildDialogButton(
                        label: "RETRY",
                        icon: Icons.replay_rounded,
                        color: const Color(0xFF0288D1),
                        onTap: () {
                          Navigator.pop(context); // Close dialog
                          if (widget.isFreePlay) {
                            game.reset(); // Reset for free play
                          } else {
                            Navigator.pop(context); // Go home for Daily (cannot retry)
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fade(duration: 300.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
    );
  }

  // Helper for skeuomorphic dialog buttons
  Widget _buildDialogButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Depth layer
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          // Main layer
          Transform.translate(
            offset: const Offset(0, -4),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _requestHint() {
    if (game.isGameOver || game.hintsUsed >= GameLogic.maxHints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No more hints available"),
          backgroundColor: Color(0xFFFF4D6D),
        ),
      );
      return;
    }

    AdManager().showRewardedAd(() {
      game.useHint();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hint used! ${game.lastHintMessage}"),
          backgroundColor: const Color(0xFF7C3AED),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background inherits from theme
      appBar: AppBar(
        title: Text(widget.isFreePlay ? "FREE PLAY" : "DAILY PUZZLE", 
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
          if (!game.isGameOver)
            TextButton.icon(
              onPressed: _requestHint,
              icon: const Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 18),
              label: Text(
                "${game.hintsUsed}/${GameLogic.maxHints}", 
                style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)
              ),
            ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showStats,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ambient glow removed for light theme
          
          SafeArea(
            child: Column(
              children: [
                const Divider(color: Colors.white10, height: 1),
                
                Flexible(
                  flex: 5,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Transform.translate(
                        offset: Offset(_shakeOffset, 0),
                        child: GameGrid(key: _gridKey, game: game),
                      ),
                    ),
                  ),
                ),
                
                // Ad Banner Area
                if (AdManager().isBannerLoaded && AdManager().bannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: AdManager().bannerAd!.size.width.toDouble(),
                    height: AdManager().bannerAd!.size.height.toDouble(),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: AdWidget(ad: AdManager().bannerAd!),
                  ),
                  
                Flexible(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
                      child: EnglishKeyboard(
                        game: game,
                        onBackspace: game.removeLetter,
                        onConfirm: () => game.submitGuess(
                          context,
                          onInvalidWord: _handleInvalidWord,
                          onGameOver: _handleGameOver,
                        ),
                        onKeyTap: game.addLetter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Color(0xFF22C55E), Color(0xFF7C3AED), Color(0xFFFF4D6D), Color(0xFFF59E0B)],
              createParticlePath: drawStar,
            ),
          ),
        ],
      ),
    );
  }

  // Draw star shape for confetti
  Path drawStar(Size size) {
    // Star drawing omitted for simplicity, use default built-in shapes
    // A path could be returned here if complex stars are desired
    return Path()
      ..addRect(Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
  }
}
