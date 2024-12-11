import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuizDetailScreen extends StatefulWidget {
  final String level;

  const QuizDetailScreen({super.key, required this.level});

  @override
  _QuizDetailScreenState createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  int currentQuestionIndex = 0; // 현재 질문 번호
  int correctAnswers = 0; // 맞춘 정답 수
  List<int> incorrectAnswers = []; // 오답 문제 번호
  String? selectedAnswer; // 사용자가 선택한 답
  List<dynamic> questions = []; // 퀴즈 문제를 담을 리스트

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  // JSON 파일을 읽어서 퀴즈 데이터를 로드하는 함수
  Future<void> _loadQuizData() async {
    // quiz_data.json 파일 읽기
    String jsonString = await rootBundle.loadString('assets/quiz_data.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);

    // 선택된 레벨에 맞는 문제를 로드
    setState(() {
      questions = jsonData[widget.level];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // 데이터 로딩 중
      );
    }

    final question = questions[currentQuestionIndex]; // 현재 문제

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "${widget.level} Quiz",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${currentQuestionIndex + 1}. ${question['question']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...question['answers'].map<Widget>((answer) {
              return RadioListTile<String>(
                title: Text(answer),
                value: answer,
                groupValue: selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    selectedAnswer = value; // 사용자가 선택한 답 저장
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 20),
            if (currentQuestionIndex < questions.length - 1)
              ElevatedButton(
                onPressed: () {
                  if (selectedAnswer == question['correctAnswer']) {
                    correctAnswers++;
                  } else {
                    incorrectAnswers.add(currentQuestionIndex + 1); // 오답 저장
                  }
                  setState(() {
                    currentQuestionIndex++; // 다음 문제로 이동
                    selectedAnswer = null; // 선택된 답 초기화
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white, // 버튼 글씨 색을 검정색으로 설정
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 10), // 버튼 크기 조정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
                  ),
                  side: const BorderSide(
                      color: Colors.black, width: 1), // 버튼 테두리 색과 두께 설정
                ),
                child: const Text(
                  '다음 문제',
                  style: TextStyle(
                    fontSize: 15, // 글씨 크기 설정
                    fontWeight: FontWeight.normal, // 글씨 두껍게 설정
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: () {
                  if (selectedAnswer == question['correctAnswer']) {
                    correctAnswers++;
                  } else {
                    incorrectAnswers.add(currentQuestionIndex + 1); // 오답 저장
                  }

                  // 모든 문제를 다 풀었으므로 결과를 확인
                  _showResultDialog();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white, // 버튼 글씨 색을 검정색으로 설정
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 10), // 버튼 크기 조정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
                  ),
                  side: const BorderSide(
                      color: Colors.black, width: 1), // 버튼 테두리 색과 두께 설정
                ),
                child: const Text(
                  '제출',
                  style: TextStyle(
                    fontSize: 15, // 글씨 크기 설정
                    fontWeight: FontWeight.normal, // 글씨 두껍게 설정
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 모든 문제를 푼 후 결과 창을 띄우는 함수
  void _showResultDialog() {
    final nextLevel = _getNextLevel(widget.level);

    if (correctAnswers >= 8) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '결과',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "$correctAnswers 점",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "$nextLevel 으로 레벨 업!",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    '퀴즈 메인으로',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '결과',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "$correctAnswers 점",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '다시 한 번 풀어볼까요?',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "오답: ${incorrectAnswers.join(', ')}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    '퀴즈 메인으로',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

// 현재 레벨에 맞는 다음 레벨 반환
  String _getNextLevel(String currentLevel) {
    switch (currentLevel) {
      case "Beginner":
        return "Medium";
      case "Medium":
        return "Advanced";
      case "Advanced":
        return "Professional";
      default:
        return "Professional"; // Professional이면 더 이상 레벨 업이 없으므로 "Professional" 반환
    }
  }
}
