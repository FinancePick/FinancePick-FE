import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 단어 항목 모델
class Word {
  final int id;
  final String term;
  final String meaning;

  Word({required this.id, required this.term, required this.meaning});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as int,
      term: json['word'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

/// 서버 페이지 응답 모델 (Spring Data Page 구조)
class VocabPage {
  final List<Word> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number; // 0-based 페이지 인덱스
  final bool first;
  final bool last;

  VocabPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
  });

  factory VocabPage.fromJson(Map<String, dynamic> json) {
    final raw = json['content'] as List<dynamic>;
    return VocabPage(
      content:
          raw.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList(),
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      size: json['size'] as int,
      number: json['number'] as int,
      first: json['first'] as bool,
      last: json['last'] as bool,
    );
  }
}

/// 단어장 API 호출 서비스
class WordService {
  static const _baseUrl = 'http://138.2.123.184/api/word';

  /// SharedPreferences 에 저장된 JWT 토큰을 반환합니다.
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('인증 토큰이 없습니다. 로그인해주세요.');
    }
    return token;
  }

  /// 페이지 단위로 단어 목록을 조회합니다.
  /// [page]: 0부터 시작하는 페이지 인덱스
  /// [size]: 페이지당 항목 수
  Future<VocabPage> fetchVocabularyPage({
    required int page,
    required int size,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/list').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );
    final resp = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (resp.statusCode != 200) {
      throw Exception('단어장 페이지 조회 실패: ${resp.statusCode}');
    }
    final jsonMap =
        jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return VocabPage.fromJson(jsonMap);
  }
}
