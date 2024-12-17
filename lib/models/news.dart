import 'package:html_unescape/html_unescape.dart';

class News {
  final String title; // 뉴스 제목
  final String description; // 뉴스 요약
  final String url; // 뉴스 원본 링크
  bool isFavorite; // 즐겨찾기 상태

  // 생성자
  News({
    required this.title,
    required this.description,
    required this.url,
    this.isFavorite = false, // 기본값: 즐겨찾기 상태 아님
  });

  // JSON 데이터를 Dart 객체로 변환
  factory News.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();
    return News(
      title: unescape.convert(json['title'] ?? "No Title"),
      description: unescape.convert(json['description'] ?? "No Description"),
      url: json['link'] ?? "",
    );
  }

  // 즐겨찾기 상태 토글 메서드
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}
