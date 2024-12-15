import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://138.2.123.184/api/auth'; // 서버 URL

  // 1. 로그인
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      print("서버 응답 상태 코드: ${response.statusCode}");
      print("서버 응답 메시지: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final email = username; // 이메일 그대로 사용

        // SharedPreferences에 토큰과 이메일 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_email', email); // 이메일 저장

        print("저장된 이메일: $email");
        return true;
      } else {
        print("로그인 실패: ${response.body}");
        return false;
      }
    } catch (e) {
      print("로그인 중 오류 발생: $e");
      return false;
    }
  }

  // 2. 회원가입
  Future<bool> signUp(String username, String password) async {
    final url = Uri.parse('$baseUrl/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      // 디버깅 로그 출력
      final decodedResponse = utf8.decode(response.bodyBytes);
      print("서버 응답 상태 코드: ${response.statusCode}");
      print("서버 응답 메시지: $decodedResponse");

      if (response.statusCode == 200) {
        print("회원가입 성공!");
        return true; // 성공 시 true 반환
      } else {
        print("회원가입 실패 조건 실행됨");
        return false; // 실패 시 false 반환
      }
    } catch (e) {
      print("회원가입 중 예외 발생: $e");
      return false; // 예외 처리 시 false 반환
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$baseUrl/change-password');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        print("비밀번호 수정 성공");
        return true;
      } else {
        print("비밀번호 수정 실패: ${response.body}");
        return false;
      }
    } catch (e) {
      print("비밀번호 수정 중 오류 발생: $e");
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // 저장된 토큰 가져오기

    if (token == null) {
      print("토큰이 존재하지 않습니다. 로그인이 필요합니다.");
      return false;
    }

    final url = Uri.parse('$baseUrl/delete-account');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token', // 인증 토큰 헤더에 추가
        },
      );

      if (response.statusCode == 200) {
        print("회원 탈퇴 성공");
        return true;
      } else {
        print("회원 탈퇴 실패: ${response.body}");
        return false;
      }
    } catch (e) {
      print("회원 탈퇴 중 오류 발생: $e");
      return false;
    }
  }
}
