// lib/models/quiz_word.dart

class QuizWord {
  final String term;

  QuizWord({required this.term});

  factory QuizWord.fromJson(Map<String, dynamic> json) {
    final rawTerm = json['term'] ?? json['correctOption'];
    if (rawTerm == null || rawTerm is! String) {
      throw Exception("term is null or not a string: $json");
    }
    return QuizWord(term: rawTerm);
  }
}
