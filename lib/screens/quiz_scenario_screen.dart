import 'package:flutter/material.dart';

class ScenarioQuizScreen extends StatelessWidget {
  const ScenarioQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("실전 적용하기 퀴즈"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "시나리오 기반 퀴즈 화면입니다.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
