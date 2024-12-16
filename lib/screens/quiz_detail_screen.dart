import 'package:flutter/material.dart';
import '../repositories/quiz_service.dart'; // QuizService 추가
import '../repositories/user_service.dart'; // UserService 추가

class QuizDetailScreen extends StatefulWidget {
  final String level;

  const QuizDetailScreen({super.key, required this.level});

  @override
  _QuizDetailScreenState createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  final UserService userService = UserService(); // UserService 인스턴스 추가
  int currentQuestionIndex = 0; // 현재 질문 번호
  int correctAnswers = 0; // 맞춘 정답 수
  List<int> incorrectAnswers = []; // 오답 문제 번호
  String? selectedAnswer; // 사용자가 선택한 답
  List<dynamic> questions = []; // 퀴즈 문제를 담을 리스트
  bool isLoading = true; // 데이터 로딩 상태

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  // 서버에서 퀴즈 데이터를 가져오는 함수
  Future<void> _loadQuizData() async {
    try {
      final quizService = QuizService();
      final data = await quizService.fetchQuizData();
      setState(() {
        questions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  // 에러 메시지 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("오류 발생"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('퀴즈 데이터를 불러올 수 없습니다.')),
      );
    }

    final question = questions[currentQuestionIndex];

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
              '${currentQuestionIndex + 1}. ${question['meaning']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...question['options'].map<Widget>((answer) {
              return RadioListTile<String>(
                title: Text(answer),
                value: answer,
                groupValue: selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    selectedAnswer = value;
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 20),
            if (currentQuestionIndex < questions.length - 1)
              _buildNextButton(question)
            else
              _buildSubmitButton(question),
          ],
        ),
      ),
    );
  }

  // 다음 문제 버튼
  Widget _buildNextButton(Map<String, dynamic> question) {
    return ElevatedButton(
      onPressed: () {
        _processAnswer(question);
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
        });
      },
      style: _buttonStyle(),
      child: const Text(
        '다음 문제',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
      ),
    );
  }

  // 제출 버튼
  Widget _buildSubmitButton(Map<String, dynamic> question) {
    return ElevatedButton(
      onPressed: () async {
        _processAnswer(question);

        // 레벨 업 로직 추가
        if (correctAnswers >= 8 && widget.level != "Professional") {
          bool success = await userService.levelUp();
          _showResultDialog(levelUpSuccess: success);
        } else {
          _showResultDialog(levelUpSuccess: false);
        }
      },
      style: _buttonStyle(),
      child: const Text(
        '제출',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
      ),
    );
  }

  // 정답 처리
  void _processAnswer(Map<String, dynamic> question) {
    if (selectedAnswer == question['correctOption']) {
      correctAnswers++;
    } else {
      incorrectAnswers.add(currentQuestionIndex + 1);
    }
  }

  // 결과 다이얼로그 (UI 변경 없음)
  void _showResultDialog({required bool levelUpSuccess}) {
    final nextLevel = _getNextLevel(widget.level);

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
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              if (levelUpSuccess && widget.level != "Professional")
                Text(
                  "$nextLevel 으로 레벨 업!",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                )
              else
                const Text(
                  '레벨업 실패 ...',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  '퀴즈 메인으로',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 다음 레벨 반환
  String _getNextLevel(String currentLevel) {
    switch (currentLevel) {
      case "Beginner":
        return "Medium";
      case "Medium":
        return "Advanced";
      case "Advanced":
        return "Professional";
      default:
        return "Professional";
    }
  }

  // 버튼 스타일
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: const BorderSide(color: Colors.black, width: 1),
    );
  }
}
