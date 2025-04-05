import 'package:flutter/material.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> words = [
      {'term': '금리', 'meaning': '이자율과 관련된 경제 용어'},
      {'term': '인플레이션', 'meaning': '물가 상승을 의미'},
      {'term': 'GDP', 'meaning': '국내 총생산을 나타내는 지표'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20, // ← 자연스러운 좌측 여백
        title: const Text(
          "단어장",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24, // ← 다른 화면과 통일된 크기
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: words.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 24, thickness: 1, color: Color(0xFFF0F0F0)),
        itemBuilder: (context, index) {
          final word = words[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 단어 (좌측 고정 너비)
              SizedBox(
                width: 100,
                child: Text(
                  word['term']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ),
              // 뜻 (우측 확장)
              Expanded(
                child: Text(
                  word['meaning']!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
