import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news.dart';
import '../services/open_ai_services.dart'; // OpenAI 서비스 추가

class NewsDetailScreen extends StatefulWidget {
  final News news; // News 객체를 전달받음
  final Widget? bottomNavigationBar;

  const NewsDetailScreen({
    super.key,
    required this.news,
    this.bottomNavigationBar,
  });

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final OpenAIService _openAIService = OpenAIService(); // OpenAI 서비스 인스턴스
  late Future<String> summaryFuture; // 뉴스 요약 데이터를 위한 Future

  @override
  void initState() {
    super.initState();
    // OpenAI API를 통해 뉴스 설명 요약
    summaryFuture = _openAIService.summarizeNews(widget.news.description);
  }

  // 외부 브라우저에서 URL 열기
  Future<void> _openNewsLink() async {
    String? newsUrl = widget.news.url;

    // URL이 비어있거나 null인지 확인
    if (newsUrl == null || newsUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("유효한 뉴스 링크가 없습니다.")),
      );
      return;
    }

    // URL이 http나 https로 시작하지 않으면 보정
    if (!newsUrl.startsWith("http")) {
      newsUrl = "https://$newsUrl";
    }

    final Uri uri = Uri.parse(newsUrl);

    // 외부 브라우저에서 링크 열기
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $newsUrl");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("링크를 열 수 없습니다: $newsUrl")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "뉴스 요약 읽기",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              widget.news.title, // News 객체의 제목 사용
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // 뉴스 요약 (OpenAI API 사용)
            FutureBuilder<String>(
              future: summaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator()); // 로딩 상태
                } else if (snapshot.hasError) {
                  return Text(
                    "요약을 불러올 수 없습니다: ${snapshot.error}",
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ); // 오류 상태
                } else {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      snapshot.data ?? "요약된 뉴스가 없습니다.",
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ); // 요약 표시
                }
              },
            ),

            const SizedBox(height: 16),

            // 뉴스 전문 보기 링크
            Row(
              children: [
                const Text(
                  "뉴스 전문이 궁금하다면?",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                IconButton(
                  onPressed: _openNewsLink, // 외부 브라우저에서 링크 열기
                  icon: const Icon(Icons.open_in_new, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          widget.bottomNavigationBar ?? const SizedBox.shrink(), // 기본값 처리
    );
  }
}
