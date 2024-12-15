import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'personal_info_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String _userName = ''; // 이메일에서 @ 앞까지 추출한 값 저장
  String _userLevel = '로딩 중...'; // 서버에서 가져올 유저 레벨

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUserLevel();
  }

  // 저장된 이메일에서 이름 부분만 가져오는 함수
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? 'user@domain.com';

    print("SharedPreferences에서 가져온 이메일: $email");

    // @ 앞부분만 추출
    final name = email.split('@')[0];

    setState(() {
      _userName = name;
    });
  }

  // 서버에서 유저 레벨 가져오는 함수
  Future<void> _loadUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // 저장된 토큰 가져오기

    if (token == null) {
      print("토큰이 없습니다. 로그인 상태를 확인해주세요.");
      return;
    }

    final url = Uri.parse('http://138.2.123.184/api/auth/myService');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("서버에서 가져온 유저 데이터: $data");

        setState(() {
          _userLevel = data['level'] ?? '알 수 없음'; // 레벨 값 설정
        });
      } else {
        print("유저 레벨 가져오기 실패: ${response.statusCode}");
        setState(() {
          _userLevel = '불러오기 실패';
        });
      }
    } catch (e) {
      print("오류 발생: $e");
      setState(() {
        _userLevel = '오류 발생';
      });
    }
  }

  // 로그아웃 함수
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // 저장된 토큰 삭제
    await prefs.remove('user_email'); // 저장된 이메일 삭제
    print("로그아웃 성공: 토큰 및 이메일 삭제됨");

    // 로그인 화면으로 이동
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, // 모든 이전 화면 제거
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 10, top: 25),
          child: Text(
            "마이 페이지",
            style: TextStyle(
              fontSize: 28,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.black12,
            child: Icon(Icons.person, size: 50, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Text(
            "$_userName 님", // 추출한 이름 표시
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          // Level 표시
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Level:",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(
                  _userLevel, // 서버에서 가져온 레벨 표시
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          const Divider(thickness: 1, height: 1, color: Colors.black12),
          ListTile(
            title: const Text(
              "개인 정보 관리",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyPagePersonalInfo()),
              );
            },
          ),
          const Divider(thickness: 1, height: 1, color: Colors.black12),
          const SizedBox(height: 100),
          ElevatedButton(
            onPressed: () => _logout(), // 로그아웃 함수 호출
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("로그아웃"),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
