import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../repositories/user_service.dart';
import '../repositories/quiz_service.dart';

class ScenarioQuizScreen extends StatefulWidget {
  final String level;
  const ScenarioQuizScreen({super.key, required this.level});

  @override
  State<ScenarioQuizScreen> createState() => _ScenarioQuizScreenState();
}

class _ScenarioQuizScreenState extends State<ScenarioQuizScreen> {
  final UserService userService = UserService();
  final QuizService quizService = QuizService();
  final String openAiApiKey = '';

  final TextEditingController _controller = TextEditingController();

  int currentIndex = 0;
  int correctAnswers = 0;
  List<Map<String, dynamic>> quizItems = [];
  List<Map<String, String>> answerLog = [];
  String userAnswer = '';
  bool isLoading = true;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    loadQuizData();
  }

  Future<void> loadQuizData() async {
    try {
      final quizWords = await quizService.parsedQuizWords();
      if (quizWords.isEmpty) throw Exception('단어 리스트가 비어 있습니다.');

      final wordNames = quizWords.map((e) => e.term).toList();
      debugPrint('넘겨받은 단어 목록: ${jsonEncode(wordNames)}');

      final prompt = '''
다음은 경제 용어 word 들이야. 각 단어를 바탕으로 상황 시나리오형 주관식 문제를 만들어줘. 문제는 최대한 자세한 시나리오 형식으로 나오게 해줘. JSON 형식으로 아래처럼 만들어줘. ```json 같은 마크다운 문법은 절대 포함하지 마:
[
  {"question": "상황 설명...", "answer": "단어"},
  ... 총 10개
]

단어 목록: ${jsonEncode(wordNames)}
''';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $openAiApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an economics quiz generator.'
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        final cleaned = content.replaceAll(RegExp(r'```json|```'), '').trim();
        final parsed = jsonDecode(cleaned);

        setState(() {
          quizItems = List<Map<String, dynamic>>.from(parsed);
          isLoading = false;
        });
      } else {
        throw Exception('OpenAI API 응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading quiz: $e');
      setState(() {
        quizItems = [];
        isLoading = false;
      });
    }
  }

  bool isCorrectAnswer(String input, String answer) {
    return input.replaceAll(' ', '').toLowerCase() ==
        answer.replaceAll(' ', '').toLowerCase();
  }

  void submitAnswer() async {
    final correct = quizItems[currentIndex]['answer'].toString().trim();
    final userInput = userAnswer.trim();
    final isCorrect = isCorrectAnswer(userInput, correct);

    if (isCorrect) correctAnswers++;

    answerLog.add({
      'question': quizItems[currentIndex]['question'],
      'yourAnswer': userInput,
      'correctAnswer': correct,
      'isCorrect': isCorrect.toString(),
    });

    if (currentIndex < quizItems.length - 1) {
      setState(() {
        currentIndex++;
        userAnswer = '';
        _controller.clear();
        showAnswer = false;
      });
    } else {
      bool leveledUp = false;
      if (correctAnswers >= 8 && widget.level != "Professional") {
        leveledUp = await userService.levelUp();
      }
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          score: correctAnswers,
          level: widget.level,
          levelUp: leveledUp,
          answerLog: answerLog,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (quizItems.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('퀴즈를 불러올 수 없습니다.')),
      );
    }

    final quiz = quizItems[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('시나리오 퀴즈', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${currentIndex + 1}. ${quiz['question']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            TextField(
              onChanged: (val) => setState(() => userAnswer = val),
              decoration: const InputDecoration(
                hintText: '정답을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (showAnswer)
              Text('정답: ${quiz['answer']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() => showAnswer = true);
                submitAnswer();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: const BorderSide(color: Colors.black),
              ),
              child: Text(currentIndex < quizItems.length - 1 ? '다음 문제' : '제출'),
            )
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final String level;
  final bool levelUp;
  final List<Map<String, String>> answerLog;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.level,
    required this.levelUp,
    required this.answerLog,
  });

  String get nextLevel {
    switch (level) {
      case 'Beginner':
        return 'Medium';
      case 'Medium':
        return 'Advanced';
      case 'Advanced':
        return 'Professional';
      default:
        return 'Professional';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('퀴즈 결과', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('결과',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('$score 점', style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                levelUp ? 'Medium으로 레벨 업!' : '레벨업 실패 ...',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const Text('문제별 정오답',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              for (final log in answerLog)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Q. ${log['question']}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('내 답: ${log['yourAnswer']}'),
                      Text('정답: ${log['correctAnswer']}'),
                      Text('결과: ${log['isCorrect'] == 'true' ? '정답' : '오답'}'),
                    ],
                  ),
                ),
              const Divider(),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('퀴즈 메인으로',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
