import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../game/game_screen.dart';
import '../game/game_logic.dart';
import '../ads/ad_manager.dart';
import '../stats/stats_screen.dart';
import '../help/help_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GameLogic _game;

  @override
  void initState() {
    super.initState();
    _game = GameLogic(); // Default instance just to manage global stats
    _game.addListener(_onGameChanged);
  }

  @override
  void dispose() {
    _game.removeListener(_onGameChanged);
    super.dispose();
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  void _launchCoffeeUrl() async {
    final Uri url = Uri.parse('https://ko-fi.com/abderridr');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch coffee url');
    }
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => const HelpScreen(),
    );
  }

  void _showStats() async {
    // Refresh stats before showing to ensure they are up to date
    await _game.reloadStats();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatsScreen(game: _game),
    );
  }

  void _navigateToGame({required bool isFreePlay}) {
    // 50% chance to show interstitial ad on navigation
    if (Random().nextBool()) {
      AdManager().showInterstitialAd();
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GameScreen(isFreePlay: isFreePlay),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF333333)),
            onPressed: _showHelp,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Color(0xFF333333)),
            onPressed: _showStats,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D Skeuomorphic Title (Matching Button Style)
              Stack(
                children: [
                  // Layer 1: Drop Shadow
                  Text(
                    "LeXo",
                    style: GoogleFonts.pacifico(
                      fontSize: 128,
                      color: const Color(0xFFB0BEC5).withOpacity(0.5),
                    ),
                  ).animate().fade(duration: 800.ms).scale(delay: 200.ms)
                  .custom(builder: (context, value, child) => Transform.translate(offset: const Offset(2, 6), child: child)),

                  // Layer 2: Bottom depth edge (3D thickness)
                  Text(
                    "LeXo",
                    style: GoogleFonts.pacifico(
                      fontSize: 128,
                      color: const Color(0xFF01579B), // Dark royal blue (Depth)
                    ),
                  ).animate().fade(duration: 800.ms).scale(delay: 200.ms)
                  .custom(builder: (context, value, child) => Transform.translate(offset: const Offset(0, 5), child: child)),

                  // Layer 3: Main body with Gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF4FC3F7), // light sky blue
                        Color(0xFF0288D1), // rich azure blue
                      ],
                    ).createShader(bounds),
                    child: Text(
                      "LeXo",
                      style: GoogleFonts.pacifico(
                        fontSize: 128,
                        color: Colors.white, // Color is overridden by ShaderMask
                      ),
                    ),
                  ).animate().fade(duration: 800.ms).scale(delay: 200.ms),
                ],
              ),
                
                const SizedBox(height: 80),

                // Play Free Button
                _buildMenuButton(
                  "PLAY FREE",
                  Icons.play_arrow_rounded,
                  () => _navigateToGame(isFreePlay: true),
                ).animate().fade(delay: 600.ms).slideY(begin: 0.5),

                const SizedBox(height: 20),

                // Daily Word Button
                _buildMenuButton(
                  "DAILY WORD",
                  Icons.calendar_today_rounded,
                  () => _navigateToGame(isFreePlay: false),
                ).animate().fade(delay: 800.ms).slideY(begin: 0.5),

                const SizedBox(height: 20),

                // Buy me a coffee Button
                _buildMenuButton(
                  "Buy me a coffee",
                  Icons.coffee_rounded,
                  _launchCoffeeUrl,
                ).animate().fade(delay: 1000.ms).slideY(begin: 0.5),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 60, // Total height to accommodate the 56 base + drop shadow
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xFFB0BEC5), // Drop shadow color
              blurRadius: 12,
              offset: Offset(2, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Layer 2: Bottom depth edge (shifted down)
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              height: 56, // Size: ~56dp
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF01579B), // dark royal blue
                  borderRadius: BorderRadius.circular(999), 
                ),
              ),
            ),
            // Layer 1: Base gradient body
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF4FC3F7), // light sky blue
                      Color(0xFF0288D1), // rich azure blue
                    ],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Layer 4 / Content container
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
