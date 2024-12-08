import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

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
          // 프로필 섹션
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.black12,
            child: Icon(Icons.person, size: 50, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const Text(
            "홍길동 님",
            textAlign: TextAlign.center,
            style: TextStyle(
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Level:",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(
                  "Beginner",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          // 설정 메뉴
          const Divider(thickness: 1, height: 1, color: Colors.black12),
          ListTile(
            title: const Text(
              "개인 정보 관리",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            onTap: () {
              // 개인 정보 관리 페이지로 이동
              print("개인 정보 관리 선택");
            },
          ),
          const Divider(thickness: 1, height: 1, color: Colors.black12),
          ListTile(
            title: const Text(
              "앱 설정",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            onTap: () {
              // 앱 설정 페이지로 이동
              print("앱 설정 선택");
            },
          ),

          const Divider(thickness: 1, height: 1, color: Colors.black12),
          const SizedBox(height: 100),
          // 로그아웃 버튼
          ElevatedButton(
            onPressed: () {
              // 로그아웃 로직 추가
              print("로그아웃 실행");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200], // 연한 회색
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
