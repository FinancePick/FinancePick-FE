import 'package:flutter/material.dart';
import 'quiz_detail_screen.dart';
import 'vocabulary_screen.dart'; // 단어장 화면 import

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> levels = [
      {"level": "기초 다지기", "description": "간단한 단어 - 뜻 매칭 연습"},
      {"level": "실전 적용하기", "description": "시나리오 기반으로 연습해보세요"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16, top: 30),
          child: Text(
            "퀴즈",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 👉 단어장 배너 추가 부분
            _buildVocabularyBanner(context),

            const SizedBox(height: 24),
            const Text(
              "레벨업에 도전해보세요!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),

            // 👉 퀴즈 리스트
            Expanded(
              child: ListView.separated(
                itemCount: levels.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 25),
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return _buildLevelTile(
                    context,
                    level["level"]!,
                    level["description"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 퀴즈 항목
  Widget _buildLevelTile(
      BuildContext context, String level, String description) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.bookmark_border, size: 28, color: Colors.black),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizDetailScreen(level: level),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(64, 36),
            shape: const StadiumBorder(),
          ),
          child: const Text("Go"),
        ),
      ],
    );
  }

  // 🔹 단어장 배너 위젯
  Widget _buildVocabularyBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VocabularyScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: const Row(
          children: [
            Icon(Icons.menu_book_outlined, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "단어장 복습하기",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "퀴즈에서 나온 단어들을 다시 볼 수 있어요",
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
