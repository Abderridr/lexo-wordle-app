import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'word_list.dart';
import '../data/answers.dart';
import '../data/dictionary.dart';

enum LetterColor { unknown, absent, present, correct }

class GameLogic extends ChangeNotifier {
  static const int maxAttempts = 6;
  static const int wordLength = 5;

  late String dailyWord;
  String currentGuess = "";
  List<String> guesses = [];
  Map<String, LetterColor> letterStates = {}; // Keyboard coloring tracking

  // Game flow states
  bool isGameOver = false;
  bool isWinner = false;
  String invalidWordMessage = ""; // For shake animation / snackbar

  // Stats
  int gamesPlayed = 0;
  int gamesWon = 0;
  int currentStreak = 0;
  int maxStreak = 0;
  List<int> guessDistribution = List.filled(6, 0);

  int hintsUsed = 0;
  List<int> hintedIndices = []; // Indices of dailyWord already revealed as hints
  String lastHintMessage = "";
  static const int maxHints = 2;

  final bool isFreePlay;

  GameLogic({this.isFreePlay = false}) {
    _initializeGame();
  }

  void reset() {
    if (!isFreePlay) return;
    
    // Clear state
    currentGuess = "";
    guesses = [];
    letterStates = {};
    isGameOver = false;
    isWinner = false;
    invalidWordMessage = "";
    hintsUsed = 0;
    hintedIndices = [];
    lastHintMessage = "";
    
    // Re-pick word
    final random = Random();
    dailyWord = answers[random.nextInt(answers.length)];
    dailyWord = normalizeWord(dailyWord);
    
    notifyListeners();
  }

  void _initializeGame() async {
    // Always load global stats so they are available in all modes
    await _loadStats();
    
    if (isFreePlay) {
      // Pick random word from answers
      final random = Random();
      dailyWord = answers[random.nextInt(answers.length)];
      dailyWord = normalizeWord(dailyWord);
      notifyListeners();
    } else {
      // Daily logic
      int daysSinceEpoch = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(0)).inDays;
      dailyWord = answers[daysSinceEpoch % answers.length];
      dailyWord = normalizeWord(dailyWord);
      await _loadDailyState(daysSinceEpoch);
      notifyListeners();
    }
  }

  Future<void> _loadStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    gamesPlayed = prefs.getInt('totalPlayed') ?? 0;
    gamesWon = prefs.getInt('totalWon') ?? 0;
    currentStreak = prefs.getInt('streak') ?? 0;
    maxStreak = prefs.getInt('maxStreak') ?? 0;
    for (int i = 0; i < 6; i++) {
      guessDistribution[i] = prefs.getInt('dist_$i') ?? 0;
    }
  }

  Future<void> _saveStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalPlayed', gamesPlayed);
    await prefs.setInt('totalWon', gamesWon);
    await prefs.setInt('streak', currentStreak);
    await prefs.setInt('maxStreak', maxStreak);
    for (int i = 0; i < 6; i++) {
      await prefs.setInt('dist_$i', guessDistribution[i]);
    }
  }

  Future<void> reloadStats() async {
    await _loadStats();
    notifyListeners();
  }

  Future<void> _loadDailyState(int dayIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lastPlayedDay = prefs.getInt('lastPlayedDay') ?? -1;
    if (lastPlayedDay == dayIndex) {
      // Load progress
      guesses = prefs.getStringList('guesses_$dayIndex') ?? [];
      isGameOver = prefs.getBool('isGameOver_$dayIndex') ?? false;
      isWinner = prefs.getBool('isWinner_$dayIndex') ?? false;
      hintsUsed = prefs.getInt('hintsUsed_$dayIndex') ?? 0;
      hintedIndices = (prefs.getStringList('hintedIndices_$dayIndex') ?? [])
          .map((e) => int.parse(e))
          .toList();

      // Rebuild letter states from previous guesses
      for (var guess in guesses) {
        _updateLetterStates(guess);
      }
    } else {
      // New day, clear old progress if needed (could be kept for history, but ignored for daily state)
      // If user lost streak by skipping a day
      if (lastPlayedDay != -1 && dayIndex - lastPlayedDay > 1) {
        currentStreak = 0;
        await _saveStats();
      }
    }
  }

  Future<void> _saveDailyState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int daysSinceEpoch = DateTime.now().difference(DateTime.utc(2023, 1, 1)).inDays;
    prefs.setInt('lastPlayedDay', daysSinceEpoch);
    prefs.setStringList('guesses_$daysSinceEpoch', guesses);
    prefs.setBool('isGameOver_$daysSinceEpoch', isGameOver);
    prefs.setBool('isWinner_$daysSinceEpoch', isWinner);
    prefs.setInt('hintsUsed_$daysSinceEpoch', hintsUsed);
    prefs.setStringList(
      'hintedIndices_$daysSinceEpoch',
      hintedIndices.map((e) => e.toString()).toList(),
    );
  }

  void addLetter(String letter) {
    if (isGameOver) return;
    if (currentGuess.length < wordLength) {
      currentGuess += letter;
      invalidWordMessage = "";
      notifyListeners();
    }
  }

  void removeLetter() {
    if (isGameOver) return;
    if (currentGuess.isNotEmpty) {
      currentGuess = currentGuess.substring(0, currentGuess.length - 1);
      invalidWordMessage = "";
      notifyListeners();
    }
  }

  void submitGuess(BuildContext context, {required Function onInvalidWord, required Function(bool) onGameOver}) async {
    if (isGameOver) return;
    if (currentGuess.length != wordLength) {
      invalidWordMessage = "Word must be 5 letters";
      onInvalidWord();
      notifyListeners();
      return;
    }

    String normalizedGuess = normalizeWord(currentGuess);
    // Guess validation = check if input exists in dictionary OR answers
    // Note: We use toLowerCase() comparison because the data lists are lowercase
    bool isValidWord = dictionary.contains(currentGuess.toLowerCase()) || 
                       answers.contains(currentGuess.toLowerCase());
    
    if (!isValidWord && normalizedGuess != dailyWord) { // sometimes dailyWord is injected testing
      invalidWordMessage = "Word not in dictionary";
      onInvalidWord();
      notifyListeners();
      return;
    }

    _updateLetterStates(normalizedGuess);
    guesses.add(normalizedGuess);
    currentGuess = "";

    if (normalizedGuess == dailyWord) {
      // Win
      isGameOver = true;
      isWinner = true;
      
      gamesPlayed++;
      gamesWon++;
      currentStreak++;
      if (currentStreak > maxStreak) maxStreak = currentStreak;
      guessDistribution[guesses.length - 1]++;
      await _saveStats();
      
      if (!isFreePlay) {
        _saveDailyState();
      }
      onGameOver(true);
    } else if (guesses.length >= maxAttempts) {
      // Lose
      isGameOver = true;
      isWinner = false;
      
      gamesPlayed++;
      currentStreak = 0;
      await _saveStats();
      
      if (!isFreePlay) {
        _saveDailyState();
      }
      onGameOver(false);
    } else {
      if (!isFreePlay) _saveDailyState();
    }
    notifyListeners();
  }

  void _updateLetterStates(String guess) {
    // Process color logic for keyboard
    // Simple implementation: correct overwrites present
    for (int i = 0; i < wordLength; i++) {
        String letter = guess[i];
        if (dailyWord[i] == letter) {
            letterStates[letter] = LetterColor.correct;
        } else if (dailyWord.contains(letter)) {
            if (letterStates[letter] != LetterColor.correct) {
                letterStates[letter] = LetterColor.present;
            }
        } else {
            if (letterStates[letter] != LetterColor.correct && letterStates[letter] != LetterColor.present) {
                letterStates[letter] = LetterColor.absent;
            }
        }
    }
  }

  List<LetterColor> evaluateGuessColors(String guess) {
    List<LetterColor> result = List.filled(wordLength, LetterColor.absent);
    if (guess.isEmpty) return result;

    List<bool> wordUsed = List.filled(wordLength, false);
    List<bool> guessUsed = List.filled(wordLength, false);

    // Pass 1: Correct (Green)
    for (int i = 0; i < wordLength; i++) {
      if (guess[i] == dailyWord[i]) {
        result[i] = LetterColor.correct;
        wordUsed[i] = true;
        guessUsed[i] = true;
      }
    }

    // Pass 2: Present (Yellow)
    for (int i = 0; i < wordLength; i++) {
      if (!guessUsed[i]) {
        for (int j = 0; j < wordLength; j++) {
          if (!wordUsed[j] && guess[i] == dailyWord[j]) {
            result[i] = LetterColor.present;
            wordUsed[j] = true;
            break; // Consume only one occurrence
          }
        }
      }
    }
    return result;
  }

  void useHint() {
    if (isGameOver || hintsUsed >= maxHints) return;
    
    // Find a correct letter that the user hasn't found yet in the correct position
    // and hasn't already been hinted
    List<int> unfoundIndices = [];
    for (int i = 0; i < wordLength; i++) {
      if (hintedIndices.contains(i)) continue; // Skip already hinted
      
      bool found = false;
      for (var g in guesses) {
        if (g[i] == dailyWord[i]) {
          found = true;
          break;
        }
      }
      if (!found) unfoundIndices.add(i);
    }

    if (unfoundIndices.isNotEmpty) {
      hintsUsed++;
      // Pick a RANDOM index from eligible unfound ones
      int hintIndex = unfoundIndices[Random().nextInt(unfoundIndices.length)];
      hintedIndices.add(hintIndex);
      
      String hintLetter = dailyWord[hintIndex];
      
      // Position is 1-based for users
      lastHintMessage = "The letter '$hintLetter' is at position ${hintIndex + 1}";
      
      // Inject this into letterStates so keyboard lights up
      letterStates[hintLetter] = LetterColor.correct;
    } else {
      lastHintMessage = "You've already found all characters or used all hints!";
    }
    
    _saveDailyState();
    notifyListeners();
  }
}
