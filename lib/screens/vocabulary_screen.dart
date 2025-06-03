import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/word_list_service.dart';

// 서버 사이드 페이징 단어장 화면 (체크박스 기능 추가)
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

  // 즐겨찾기 관리를 위한 변수들
  Set<String> _favoriteWords = {};
  bool _isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadPage();
    _service.printMyWordbooks();
  }

  // SharedPreferences에서 즐겨찾기 단어들 로드
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteList = prefs.getStringList('favorite_words') ?? [];
    setState(() {
      _favoriteWords = favoriteList.toSet();
      _isLoadingFavorites = false;
    });
  }

  Future<void> _createWordbookIfNeeded() async {
    try {
      await _service.getMyWordbookIdOrThrow();
      // 이미 단어장이 있으면 안내
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미 단어장이 존재합니다'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (_) {
      // 단어장이 없으면 생성 시도
      try {
        final newId = await _service.createMyWordbook();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('단어장이 생성되었습니다 (ID: $newId)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        debugPrint('❌ 단어장 생성 실패: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('단어장 생성에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 즐겨찾기 상태 토글
  Future<void> _toggleFavorite(String wordId) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_favoriteWords.contains(wordId)) {
        _favoriteWords.remove(wordId);
      } else {
        _favoriteWords.add(wordId);
      }
    });

    await prefs.setStringList('favorite_words', _favoriteWords.toList());

    // ✅ 서버에도 반영
    try {
      final idInt = int.tryParse(wordId);
      if (idInt != null) {
        if (_favoriteWords.contains(wordId)) {
          await _service.addWordToMyWordbook(idInt);
          debugPrint('✅ 서버 단어장에 단어 추가 성공 (ID: $idInt)');
        } else {
          await _service.removeWordFromMyWordbook(idInt);
          debugPrint('✅ 서버 단어장에서 단어 제거 성공 (ID: $idInt)');
        }
      } else {
        debugPrint('⚠️ wordId 파싱 실패: $wordId');
      }
    } catch (e) {
      debugPrint('❌ 서버 단어장 반영 실패: $e');
    }

    // ✅ 스낵바 표시
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_favoriteWords.contains(wordId)
            ? '나만의 단어장에 추가되었습니다'
            : '나만의 단어장에서 제거되었습니다'),
        duration: const Duration(seconds: 1),
        backgroundColor:
            _favoriteWords.contains(wordId) ? Colors.green : Colors.grey,
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.black,
            tooltip: '단어장 생성',
            onPressed: _createWordbookIfNeeded,
          ),
        ],
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
              final wordId = w.id.toString() ??
                  '${w.term}_$index'; // ID가 있으면 사용, 없으면 임시 ID 생성
              final isFavorite = _favoriteWords.contains(wordId);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 체크박스 추가 - 위쪽 정렬을 위해 패딩 조정
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: isFavorite,
                        onChanged: _isLoadingFavorites
                            ? null
                            : (bool? value) => _toggleFavorite(wordId),
                        activeColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 단어와 뜻을 세로로 배치
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.term,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          w.meaning,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
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
