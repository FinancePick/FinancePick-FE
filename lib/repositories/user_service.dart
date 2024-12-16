import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String levelUpUrl = 'http://138.2.123.184/api/auth/level-up';

  // 레벨 업 요청
  Future<bool> levelUp() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('로그인이 필요합니다.');
    }

    try {
      final response = await http.patch(
        Uri.parse(levelUpUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('레벨 업 성공');
        return true;
      } else {
        print('레벨 업 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('레벨 업 중 오류 발생: $e');
      return false;
    }
  }
}
