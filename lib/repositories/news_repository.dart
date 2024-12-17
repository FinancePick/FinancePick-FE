import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/news.dart';

class NewsRepository {
  final Dio _dio = Dio();

  final String _clientId = ''; // 네이버 Client ID
  final String _clientSecret = ''; // 네이버 Client Secret

  Future<List<News>> fetchNews(String query, {int display = 20}) async {
    final encodedQuery = Uri.encodeComponent(query.isEmpty ? "경제" : query);

    final apiUrl =
        'https://openapi.naver.com/v1/search/news.json?query=$encodedQuery&display=$display';

    try {
      print("Request URL: $apiUrl");
      print(
          "Request Headers: X-Naver-Client-Id=$_clientId, X-Naver-Client-Secret=$_clientSecret");

      final response = await _dio.get(
        apiUrl,
        options: Options(headers: {
          'X-Naver-Client-Id': _clientId,
          'X-Naver-Client-Secret': _clientSecret,
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      final items = response.data['items'] as List<dynamic>;

      return items
          .map((json) => News.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to fetch news: $e');
    }
  }
}
