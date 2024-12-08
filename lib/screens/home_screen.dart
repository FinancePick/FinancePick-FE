import 'package:flutter/material.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<String> favoriteNews; // 즐겨찾기된 뉴스 리스트
  final ValueChanged<String> onFavoriteToggle; // 즐겨찾기 상태를 변경하는 콜백

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

  // 필터 목록
  final List<String> filters = ["금융", "증권", "산업", "부동산", "중소기업 / 벤처"];

  // 필터별 뉴스 데이터
  final Map<String, List<String>> filterNews = {
    "금융": [
      "한은, 15년 만에 기준금리 두 달 연속 인하",
      "은행 예금 금리 상승, 저축성 상품 인기",
      "정부, 금융 소비자 보호 강화 방안 발표",
    ],
    "증권": [
      "코스피, 2500선 돌파... 1년 내 최고치",
      "테슬라, 주가 20% 급등 소식에 글로벌 증시 활황",
      "ETF 인기 상승, 20대 투자자 급증",
    ],
    "산업": [],
    "부동산": [
      "서울 아파트 매매가, 3개월 연속 상승세",
      "정부, 1주택자 세제 완화 정책 발표",
      "신규 주택 공급, 수도권 지역 집중 발표",
    ],
    "중소기업 / 벤처": [
      "스타트업 투자 유치 성공, AI 플랫폼 기술 개발",
      "중소기업청, 디지털 전환 지원금 확대 발표",
      "벤처 캐피탈, 2024년 유망 기업에 1조 투자 계획",
    ],
  };

  @override
  Widget build(BuildContext context) {
    final newsItems = filterNews[selectedFilter] ?? [];

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
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: newsItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _buildNewsItem(context, newsItems[index]);
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
  Widget _buildNewsItem(BuildContext context, String title) {
    final isFavorite = widget.favoriteNews.contains(title);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? Colors.yellow : Colors.black,
        ),
        onPressed: () {
          widget.onFavoriteToggle(title); // 즐겨찾기 상태 토글
        },
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // 뉴스 클릭 시 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(title: title),
          ),
        );
      },
    );
  }
}
