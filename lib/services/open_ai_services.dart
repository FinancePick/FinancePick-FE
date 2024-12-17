import 'package:dio/dio.dart';

class OpenAIService {
  final Dio _dio = Dio();
  final String _apiKey = '';

  Future<String> summarizeNews(String articleContent) async {
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await _dio.post(
        apiUrl,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        }),
        data: {
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a helpful assistant that summarizes articles in Korean." //명령어 설정
            },
            {
              "role": "user",
              "content":
                  "Summarize the following article in Korean:\n$articleContent" //명령어 설정정
            }
          ],
          "max_tokens": 2000,
          "temperature": 0.7,
        },
      );

      final summary = response.data['choices'][0]['message']['content'];
      return summary.trim();
    } catch (e) {
      throw Exception('Failed to summarize news: $e');
    }
  }
}
