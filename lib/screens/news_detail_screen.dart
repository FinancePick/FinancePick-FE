import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {
  final String title;
  final Widget? bottomNavigationBar;

  const NewsDetailScreen({
    super.key,
    required this.title,
    this.bottomNavigationBar,
  });

  // 외부 URL 열기
  void _openNewsLink() async {
    const String url = "https://news.example.com"; // 실제 뉴스 링크로 변경
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint("Could not launch $url");
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
              title,
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
              child: const Text(
                "한국은행이 기준금리를 0.25%P 인하하며 두 달 연속 금리 인하를 단행, 2008년 이후 처음으로 통화정책 전환(피벗)을 실행했습니다.\n\n"
                "올해와 내년 경제성장률 전망이 각각 2.2%, 1.9%로 낮아짐에 따라 경기 침체 우려가 커지고 있습니다.\n\n"
                "경기 부진 속도를 완화하고 내수 시장을 회복하기 위해 금리 인하로 시중에 돈을 풀겠다는 전략입니다.",
                style: TextStyle(
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
