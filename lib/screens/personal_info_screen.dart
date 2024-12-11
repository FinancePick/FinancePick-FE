import 'package:flutter/material.dart';

class MyPagePersonalInfo extends StatefulWidget {
  const MyPagePersonalInfo({super.key});

  @override
  _MyPagePersonalInfoState createState() => _MyPagePersonalInfoState();
}

class _MyPagePersonalInfoState extends State<MyPagePersonalInfo> {
  // 개인정보
  String name = "홍길동";
  String email = "hong@example.com";
  String password = "password123"; // 초기 비밀번호

  // 수정 가능한 값
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // 폼 유효성 검사
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // 초기값 설정
    nameController.text = name;
    emailController.text = email;
  }

  // 이메일 유효성 검사
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    // 이메일 형식 체크
    String pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\b';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return '유효한 이메일 주소를 입력해주세요.';
    }
    return null;
  }

  // 비밀번호 유효성 검사
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (value.length < 8) {
      return '비밀번호는 최소 8자 이상이어야 합니다.';
    }
    return null;
  }

  // 개인정보 저장 함수
  void _savePersonalInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      // 비밀번호가 일치하지 않으면 경고
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
        );
        return;
      }

      setState(() {
        name = nameController.text;
        email = emailController.text;
        password = passwordController.text;
      });

      // 서버나 로컬 저장 로직 추가 가능

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("개인정보가 저장되었습니다.")),
      );
    }
  }

  // 개인정보 수정 취소 함수
  void _cancelEdit() {
    setState(() {
      nameController.text = name;
      emailController.text = email;
      passwordController.clear();
      confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경색
        elevation: 0, // 그림자 제거
        title: const Padding(
          padding: EdgeInsets.only(left: 2),
          child: Text(
            "개인정보 관리",
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: false, // 왼쪽 정렬
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // 폼 키 설정
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30), // 앱바와 입력란 사이 간격 추가

                // 이름 입력란
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "이름",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15), // 입력란 간격

                // 이메일 입력란
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "이메일",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 15), // 입력란 간격

                // 비밀번호 입력란
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "새 비밀번호",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 15), // 입력란 간격

                // 비밀번호 확인 입력란
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "비밀번호 확인",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호 확인을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20), // 버튼과 입력란 간 간격

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _savePersonalInfo,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // 버튼 글씨 색을 흰색으로 설정
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
                        ),
                      ),
                      child: const Text("저장"),
                    ),
                    ElevatedButton(
                        onPressed: _cancelEdit,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, // 버튼 글씨 색을 흰색으로 설정
                          backgroundColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // 둥근 모서리 설정
                          ),
                        ),
                        child: const Text("취소"))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
