import 'dart:convert';
import 'package:flutter/services.dart';

class WordService {
  Future<Map<String, String>> fetchTodayWords() async {
    // JSON 파일 읽어오기
    final String response =
        await rootBundle.loadString('assets/today_word.json');
    final List<dynamic> data = json.decode(response); // JSON 파싱

    final wordData = data.isNotEmpty ? data[0] : {};

    return {
      'word': wordData['word'] ?? '단어 없음',
      'description': wordData['description'] ?? '설명 없음',
    };
  }
}
