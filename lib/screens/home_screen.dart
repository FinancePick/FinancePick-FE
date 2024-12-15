import 'package:flutter/material.dart';
import '../repositories/news_repository.dart';
import '../models/news.dart';
import 'news_detail_screen.dart';
import '../repositories/word_services.dart'; // WordService 추가

class HomeScreen extends StatefulWidget {
  final List<News> favoriteNews; // 타입 변경: List<String> → List<News>
  final ValueChanged<News> onFavoriteToggle; // 콜백 타입 변경

  const HomeScreen({
    super.key,
    required this.favoriteNews,
    required this.onFavoriteToggle,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "금융"; // 기본 필터는 "금융"으로 설정

  // 필터 목록
  final List<String> filters = ["금융", "증권", "산업", "부동산", "중소기업 / 벤처"];

  // 뉴스 데이터를 가져오는 Future
  late Future<List<News>> newsFuture;
  late Future<Map<String, String>> wordFuture; // 오늘의 단어 데이터를 위한 변수

  @override
  void initState() {
    super.initState();
    newsFuture = fetchAllNews(); // 모든 뉴스를 가져옴
    wordFuture = fetchTodayWord(); // 오늘의 단어를 가져오는 함수 호출

    // 화면이 로드될 때 자동으로 오늘의 단어 팝업 띄우기
    Future.delayed(Duration.zero, () {
      _showTodayWordDialog(context);
    });
  }

  // 모든 뉴스 데이터를 가져오는 함수
  Future<List<News>> fetchAllNews() async {
    final repository = NewsRepository();
    return repository.fetchNews(); // API 호출하여 모든 뉴스 가져오기
  }

  // 오늘의 단어 데이터를 가져오는 함수
  Future<Map<String, String>> fetchTodayWord() async {
    final wordService = WordService();
    return wordService.fetchTodayWords(); // 오늘의 단어를 가져오는 서비스 호출
  }

  void _showTodayWordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, String>>(
          future: wordFuture, // 오늘의 단어를 가져오는 Future
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text("오류"),
                content: Text('Error: ${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("확인"),
                  ),
                ],
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return AlertDialog(
                title: const Text("오류"),
                content: const Text("오늘의 단어를 불러올 수 없습니다."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("확인"),
                  ),
                ],
              );
            }

            final wordData = snapshot.data!;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                      '오늘의 단어',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      wordData['word'] ?? '단어 없음',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      wordData['description'] ?? '설명 없음',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '레벨: ${wordData['level'] ?? '레벨 없음'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        "메인으로",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 7, top: 30),
          child: Text(
            "오늘의 경제콕",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 서브 타이틀
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: 16),
                Text(
                  "주요 뉴스를 살펴보세요!",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 필터 버튼
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: filters.map((filter) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  child: _buildFilterChip(filter,
                      isSelected: selectedFilter == filter),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // 뉴스 리스트
          Expanded(
            child: FutureBuilder<List<News>>(
              future: newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('뉴스 데이터가 없습니다.'),
                  );
                }

                final newsItems = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: newsItems.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return _buildNewsItem(context, newsItems[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 필터 버튼 UI
  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 뉴스 아이템 UI
  Widget _buildNewsItem(BuildContext context, News news) {
    final isFavorite =
        widget.favoriteNews.any((favorite) => favorite.title == news.title);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? Colors.yellow : Colors.black,
        ),
        onPressed: () {
          widget.onFavoriteToggle(news); // News 객체 전달
        },
      ),
      title: Text(
        news.title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // 뉴스 클릭 시 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(news: news),
          ),
        );
      },
    );
  }
}
