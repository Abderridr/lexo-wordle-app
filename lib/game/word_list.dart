// Original placeholder word list removed in favor of data/answers.dart and data/dictionary.dart
const List<String> wordList = []; 


const Map<String, String> wordMeanings = {
  "APPLE": "A round fruit with red or green skin",
  "HOUSE": "A building for human habitation",
  "TRAIN": "A series of connected vehicles running on a railway",
  "GHOST": "An apparition of a dead person",
  "SMILE": "A pleased, kind, or amused facial expression",
  "WATER": "A transparent, tasteless, odorless liquid",
  "PLANT": "A living organism of the kind exemplified by trees",
  "BEACH": "A pebbly or sandy shore by the ocean",
  "CHAIR": "A separate seat for one person",
  "TABLE": "A piece of furniture with a flat top and legs"
};

String normalizeWord(String input) {
  // English version just safely uppercases all entries
  return input.toUpperCase().trim();
}
