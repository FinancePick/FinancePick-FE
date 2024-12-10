import 'package:dio/dio.dart';
import '../models/news.dart';

class NewsRepository {
  final Dio _dio = Dio();

  Future<List<News>> fetchNews() async {
    const apiUrl =
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=66140dcecc614377a289e7f6e8c7c030';

    try {
      final response = await _dio.get(apiUrl);
      final articles = response.data['articles'] as List<dynamic>;

      // articles를 News 객체 리스트로 변환
      return articles
          .map((json) => News.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch news: $e');
    }
  }
}
