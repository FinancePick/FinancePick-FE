import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/word_list_service.dart';

// 나만의 단어장 화면
class MyVocabularyScreen extends StatefulWidget {
  const MyVocabularyScreen({super.key});

  @override
  _MyVocabularyScreenState createState() => _MyVocabularyScreenState();
}

class _MyVocabularyScreenState extends State<MyVocabularyScreen> {
  final WordService _service = WordService();
  List<Word> _favoriteWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteWords();
  }

  // 즐겨찾기 단어들 로드
  Future<void> _loadFavoriteWords() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_words') ?? [];

    if (favoriteIds.isEmpty) {
      setState(() {
        _favoriteWords = [];
        _isLoading = false;
      });
      return;
    }

    try {
      // TODO: 실제 구현에서는 WordService에 특정 ID들로 단어를 가져오는 메서드가 필요합니다
      // 임시로 전체 단어를 가져와서 필터링하는 방식으로 구현
      // _service.fetchWordsByIds(favoriteIds) 같은 메서드가 있다면 더 효율적입니다

      List<Word> allFavorites = [];

      // 페이지별로 단어를 가져와서 즐겨찾기 ID와 매칭
      int page = 0;
      bool hasMore = true;

      while (hasMore && allFavorites.length < favoriteIds.length) {
        final pageData =
            await _service.fetchVocabularyPage(page: page, size: 50);

        for (final word in pageData.content) {
          final wordId = word.id.toString() ??
              '${word.term}_${pageData.content.indexOf(word)}';
          if (favoriteIds.contains(wordId)) {
            allFavorites.add(word);
          }
        }

        hasMore = !pageData.last;
        page++;

        // 무한 루프 방지
        if (page > 100) break;
      }

      setState(() {
        _favoriteWords = allFavorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _favoriteWords = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('단어를 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 즐겨찾기에서 단어 제거
  Future<void> _removeFavorite(String wordId, String term) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_words') ?? [];

    favoriteIds.remove(wordId);
    await prefs.setStringList('favorite_words', favoriteIds);

    setState(() {
      _favoriteWords.removeWhere((word) {
        final id = word.id.toString() ??
            '${word.term}_${_favoriteWords.indexOf(word)}';
        return id == wordId;
      });
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\'$term\'이(가) 나만의 단어장에서 제거되었습니다'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.grey,
          action: SnackBarAction(
            label: '취소',
            onPressed: () => _undoRemove(wordId, term),
          ),
        ),
      );
    }
  }

  // 제거 취소 (되돌리기)
  Future<void> _undoRemove(String wordId, String term) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_words') ?? [];

    if (!favoriteIds.contains(wordId)) {
      favoriteIds.add(wordId);
      await prefs.setStringList('favorite_words', favoriteIds);

      // 단어장 새로고침
      _loadFavoriteWords();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('\'$term\'이(가) 다시 추가되었습니다'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // 전체 즐겨찾기 삭제
  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('나만의 단어장을 모두 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favorite_words');

      setState(() {
        _favoriteWords = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('나만의 단어장이 모두 삭제되었습니다'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '나만의 단어장',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_favoriteWords.isNotEmpty && !_isLoading)
            IconButton(
              onPressed: _clearAllFavorites,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: '전체 삭제',
            ),
          IconButton(
            onPressed: _loadFavoriteWords,
            icon: const Icon(Icons.refresh, color: Colors.black),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteWords.isEmpty
              ? _buildEmptyState()
              : _buildWordList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '아직 추가된 단어가 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '단어장에서 단어를 선택해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.book),
            label: const Text('단어장으로 가기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordList() {
    return Column(
      children: [
        // 통계 정보
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                '총 ${_favoriteWords.length}개의 단어',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),

        // 단어 리스트
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
            itemCount: _favoriteWords.length,
            separatorBuilder: (_, __) => const Divider(
              height: 16,
              thickness: 1,
              color: Color(0xFFF0F0F0),
            ),
            itemBuilder: (context, index) {
              final word = _favoriteWords[index];
              final wordId = word.id.toString() ?? '${word.term}_$index';

              return Dismissible(
                key: Key(wordId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) => _removeFavorite(wordId, word.term),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.star,
                        size: 20,
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(width: 12),
                      // 단어와 뜻을 세로로 배치
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.term,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              word.meaning,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeFavorite(wordId, word.term),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
