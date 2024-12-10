import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news; // News 객체를 전달받도록 변경
  final Widget? bottomNavigationBar;

  const NewsDetailScreen({
    super.key,
    required this.news,
    this.bottomNavigationBar,
  });

  // 외부 URL 열기
  Future<void> _openNewsLink() async {
    final Uri uri = Uri.parse(news.url); // News 객체의 url 사용
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch ${news.url}");
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
              news.title, // News 객체의 제목 사용
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // 뉴스 요약
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                news.description.isNotEmpty
                    ? news.description // News 객체의 설명 사용
                    : "뉴스 설명이 없습니다.",
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
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
                  onPressed: _openNewsLink, // 링크 연결 동작 추가
                  icon: const Icon(Icons.open_in_new, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 100),
            const Text(
              "",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          bottomNavigationBar ?? const SizedBox.shrink(), // 기본값 처리
    );
  }
}
