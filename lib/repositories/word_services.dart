import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WordService {
  final String baseUrl = 'http://138.2.123.184/api/word';

  // 오늘의 단어를 가져오는 함수
  Future<Map<String, String>> fetchTodayWords() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // 저장된 토큰 가져오기

    if (token == null) {
      throw Exception('인증 토큰이 없습니다. 로그인 해주세요.');
    }

    final url = Uri.parse('$baseUrl/today'); // 새 API 엔드포인트
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // 인증 토큰 추가
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'word': data['word'] ?? '단어 없음',
          'description': data['meaning'] ?? '설명 없음',
          'level': data['level'] ?? '레벨 없음',
        };
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오늘의 단어를 불러오는 중 오류 발생: $e');
    }
  }
}
