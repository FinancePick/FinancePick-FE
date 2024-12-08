import 'package:flutter/material.dart';
import 'news_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<String> favoriteNews; // 전체 즐겨찾기된 뉴스 리스트
  final ValueChanged<String> onFavoriteToggle; // 즐겨찾기 상태를 변경하는 콜백

  const FavoritesScreen({
    super.key,
    required this.favoriteNews,
    required this.onFavoriteToggle,
  });

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
            "즐겨찾기 한 뉴스",
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
        children: [
          const SizedBox(height: 20), // 앱바와 뉴스 리스트 사이 간격
          Expanded(
            child: favoriteNews.isEmpty
                ? const Center(
                    child: Text(
                      "즐겨찾기한 뉴스가 없습니다.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                : ListView.separated(
                    itemCount: favoriteNews.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final news = favoriteNews[index];
                      return ListTile(
                        leading: IconButton(
                          icon: const Icon(Icons.star, color: Colors.yellow),
                          onPressed: () {
                            onFavoriteToggle(news); // 즐겨찾기 상태 변경
                          },
                        ),
                        title: Text(
                          news,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetailScreen(title: news),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
