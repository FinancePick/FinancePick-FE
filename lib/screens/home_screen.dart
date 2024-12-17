import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/news_repository.dart';
import '../models/news.dart';
import 'news_detail_screen.dart';
import '../repositories/word_services.dart';

class HomeScreen extends StatefulWidget {
  final List<News> favoriteNews;
  final ValueChanged<News> onFavoriteToggle;

  const HomeScreen({
    super.key,
    required this.favoriteNews,
    required this.onFavoriteToggle,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "금융";
  final List<String> filters = ["금융", "증권", "산업", "부동산", "중소기업 / 벤처", "글로벌 경제"];
  late Future<List<News>> newsFuture;
  late Future<Map<String, String>> wordFuture;

  @override
  void initState() {
    super.initState();
    newsFuture = fetchAllNews();
    wordFuture = fetchTodayWord();

    Future.delayed(Duration.zero, () {
      _showTodayWordDialog(context);
    });
  }

  Future<List<News>> fetchAllNews() async {
    final repository = NewsRepository();
    return repository.fetchNews(selectedFilter);
  }

  Future<Map<String, String>> fetchTodayWord() async {
    final wordService = WordService();
    return wordService.fetchTodayWords();
  }

  void _showTodayWordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, String>>(
          future: wordFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              return AlertDialog(
                title: const Text("오류"),
                content: const Text("오늘의 단어를 불러올 수 없습니다."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("확인"))
                ],
              );
            }

            final wordData = snapshot.data!;
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 8)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('오늘의 단어',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text(wordData['word'] ?? '단어 없음',
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(wordData['description'] ?? '설명 없음',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white),
                      child: const Text("메인으로"),
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
        title: const Text("오늘의 경제콕",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            newsFuture = fetchAllNews();
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Text("주요 뉴스를 살펴보세요!",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black87)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: filters.map((filter) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                        newsFuture = fetchAllNews();
                      });
                    },
                    child: _buildFilterChip(filter,
                        isSelected: selectedFilter == filter),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<News>>(
                future: newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Center(child: Text('뉴스 데이터를 불러올 수 없습니다.'));
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
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNewsItem(BuildContext context, News news) {
    final ScrollController _scrollController = ScrollController();
    Timer? _timer;

    void _startScrolling() {
      const scrollDuration = Duration(milliseconds: 50);
      const scrollIncrement = 2.0;

      _timer = Timer.periodic(scrollDuration, (timer) {
        if (_scrollController.hasClients) {
          final maxScrollExtent = _scrollController.position.maxScrollExtent;
          final currentScroll = _scrollController.offset;

          if (currentScroll < maxScrollExtent) {
            _scrollController.jumpTo(currentScroll + scrollIncrement);
          } else {
            _scrollController.jumpTo(0.0);
          }
        }
      });
    }

    void _stopScrolling() {
      _timer?.cancel();
      _scrollController.jumpTo(0.0);
    }

    final isFavorite =
        widget.favoriteNews.any((favorite) => favorite.title == news.title);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsDetailScreen(news: news)),
        );
      },
      onLongPress: _startScrolling,
      onLongPressEnd: (details) => _stopScrolling(),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.yellow : Colors.black,
          ),
          onPressed: () => widget.onFavoriteToggle(news),
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: Text(
            news.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            softWrap: false,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
