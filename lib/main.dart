import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'ads/ad_manager.dart';
import 'home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdManager().initialize(); // Preload ads

  runApp(const WordleApp());
}

class WordleApp extends StatelessWidget {
  const WordleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F0EF),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF333333)),
          titleTextStyle: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w900),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
