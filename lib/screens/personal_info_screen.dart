import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/api_services.dart';

class MyPagePersonalInfo extends StatefulWidget {
  const MyPagePersonalInfo({super.key});

  @override
  _MyPagePersonalInfoState createState() => _MyPagePersonalInfoState();
}

class _MyPagePersonalInfoState extends State<MyPagePersonalInfo> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  String email = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // 유저 정보 불러오기
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('user_email') ?? "hong@example.com";
    });
  }

  // 비밀번호 변경 함수
  Future<void> _changePassword() async {
    if (newPasswordController.text != confirmNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("새 비밀번호가 일치하지 않습니다.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ApiService().changePassword(
      oldPasswordController.text,
      newPasswordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("비밀번호가 성공적으로 변경되었습니다.")),
      );
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmNewPasswordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("비밀번호 변경에 실패했습니다.")),
      );
    }
  }

  // 회원 탈퇴 함수
  Future<void> _deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final success = await ApiService().deleteAccount();

    if (success) {
      await prefs.clear(); // 로컬 데이터 삭제
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("회원 탈퇴가 완료되었습니다.")),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("회원 탈퇴에 실패했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "개인정보 관리",
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // 이메일 표시
            const Text("이메일",
                style: TextStyle(fontSize: 16, color: Colors.black54)),
            Text(
              email,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // 현재 비밀번호 입력
            TextFormField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "현재 비밀번호",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 새 비밀번호 입력
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "새 비밀번호",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 새 비밀번호 확인
            TextFormField(
              controller: confirmNewPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "새 비밀번호 확인",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // 저장 버튼
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      "비밀번호 변경",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
            ),
            const SizedBox(height: 40),

            // 회원 탈퇴 버튼
            TextButton(
              onPressed: _deleteAccount,
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.grey[200],
              ),
              child: const Text(
                "회원 탈퇴",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
