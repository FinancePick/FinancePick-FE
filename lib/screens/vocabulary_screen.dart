import 'package:flutter/material.dart';
import '../repositories/word_list_service.dart';

// 서버 사이드 페이징 단어장 화면
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  _VocabularyScreenState createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  static const int _pageSize = 10;
  int _currentPage = 0;
  late Future<VocabPage> _futurePage;
  final WordService _service = WordService();

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  void _loadPage() {
    setState(() {
      _futurePage = _service.fetchVocabularyPage(
        page: _currentPage,
        size: _pageSize,
      );
    });
  }

  void _nextPage(bool isLast) {
    if (!isLast) {
      _currentPage++;
      _loadPage();
    }
  }

  void _prevPage(bool isFirst) {
    if (!isFirst && _currentPage > 0) {
      _currentPage--;
      _loadPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '단어장',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<VocabPage>(
        future: _futurePage,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          }
          final pageData = snapshot.data!;
          final words = pageData.content;

          if (words.isEmpty) {
            return const Center(child: Text('단어가 없습니다'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 100),
            itemCount: words.length,
            separatorBuilder: (_, __) => const Divider(
              height: 24,
              thickness: 1,
              color: Color(0xFFF0F0F0),
            ),
            itemBuilder: (context, index) {
              final w = words[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      w.term,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ),
                  // 단어와 의미 사이 간격 추가
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      w.meaning,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 2,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<VocabPage>(
        future: _futurePage,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              !snapshot.hasData) {
            return const SizedBox.shrink();
          }
          final pageData = snapshot.data!;
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _prevPage(pageData.first),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                    child: const Text('이전'),
                  ),
                  const SizedBox(width: 17),
                  Text(
                    '${pageData.number + 1} / ${pageData.totalPages}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(width: 17),
                  ElevatedButton(
                    onPressed: () => _nextPage(pageData.last),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                    child: const Text('다음'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
