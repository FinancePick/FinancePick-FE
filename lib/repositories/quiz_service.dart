import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuizService {
  final String baseUrl = 'http://138.2.123.184/api/word/quiz';

  // 사용자 레벨에 맞는 퀴즈 데이터를 가져오는 함수
  Future<List<dynamic>> fetchQuizData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('로그인이 필요합니다.');
    }

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // UTF-8로 디코딩해서 JSON 파싱
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        return decodedData;
      } else {
        throw Exception('퀴즈 데이터를 불러올 수 없습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오류 발생: $e');
    }
  }
}
