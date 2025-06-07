import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

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
  static const _baseUrl = 'http://10.0.2.2:8080/api';
  int? _myWordbookId; // 유저당 하나의 단어장 ID

  /// SharedPreferences 에 저장된 JWT 토큰을 반환합니다.
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('인증 토큰이 없습니다. 로그인해주세요.');
    }
    return token;
  }

  /// 전체 단어장 페이지 단위로 조회
  Future<VocabPage> fetchVocabularyPage(
      {required int page, required int size}) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/word/list').replace(
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

  /// 단어장 ID가 없으면 예외를 던짐
  Future<int> getMyWordbookIdOrThrow() async {
    if (_myWordbookId != null) return _myWordbookId!;

    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/wordbooks/my'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final list = (decoded is List) ? decoded : decoded['content'] ?? [];
      if (list.isNotEmpty) {
        _myWordbookId = list.first['id'];
        debugPrint('📡 내 단어장 ID: $_myWordbookId');
        debugPrint('🔑 토큰: $token');

        return _myWordbookId!;
      }
    }

    throw Exception('아직 단어장이 생성되지 않았습니다. 먼저 단어장을 만들어주세요.');
  }

  /// 단어장 생성 (최초 1회)
  Future<int> createMyWordbook() async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/wordbooks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "name": "나의 단어장",
        "description": "앱에서 자동 생성됨",
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final created = jsonDecode(utf8.decode(response.bodyBytes));
      _myWordbookId = created['id'];
      return _myWordbookId!;
    } else {
      throw Exception('단어장 생성 실패');
    }
  }

  /// 단어장에 단어 추가
  Future<void> addWordToMyWordbook(int wordId) async {
    final wordbookId = await getMyWordbookIdOrThrow();
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/wordbooks/$wordbookId/words/$wordId');
    final resp = await http.post(uri, headers: {
      'Authorization': 'Bearer $token',
    });
    if (resp.statusCode != 200) {
      throw Exception('단어 추가 실패');
    }
  }

  /// 단어장에서 단어 삭제
  Future<void> removeWordFromMyWordbook(int wordId) async {
    final wordbookId = await getMyWordbookIdOrThrow();
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/wordbooks/$wordbookId/words/$wordId');
    final resp = await http.delete(uri, headers: {
      'Authorization': 'Bearer $token',
    });
    if (resp.statusCode != 200) {
      throw Exception('단어 삭제 실패');
    }
  }

  /// 내 단어장 목록을 터미널에 출력 (디버그용)
  Future<void> printMyWordbooks() async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/wordbooks/my');

    final resp = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (resp.statusCode != 200) {
      throw Exception('❌ 단어장 목록 조회 실패');
    }

    final decoded =
        jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    final content = decoded['content'] as List<dynamic>;
    debugPrint('📦 내 단어장 목록: $content');
  }

  /// 나의 단어장에 있는 단어들 조회
  Future<List<Word>> fetchWordsInMyWordbook() async {
    final token = await _getToken();
    final wordbookId = await getMyWordbookIdOrThrow();
    final uri = Uri.parse('$_baseUrl/wordbooks/$wordbookId/words');

// 로그 출력
    debugPrint('🌐 단어장 요청 URI: $uri');
    debugPrint('📩 Authorization 헤더: Bearer $token');

    final resp = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    // ✅ 여기에 디버그 프린트 추가
    debugPrint('📥 응답 코드: ${resp.statusCode}');
    debugPrint('📥 응답 본문: ${utf8.decode(resp.bodyBytes)}');

    if (resp.statusCode != 200) {
      throw Exception('나의 단어장 조회 실패');
    }

    final data =
        jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    final words = data['words'] as List<dynamic>;
    return words.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> debugPrintMyWordbookWords() async {
    try {
      final words = await fetchWordsInMyWordbook();
      if (words.isEmpty) {
        debugPrint('📭 나의 단어장에는 단어가 없습니다.');
      } else {
        debugPrint('📚 나의 단어장에 있는 단어 목록:');
        for (var word in words) {
          debugPrint('- ${word.id}: ${word.term} (${word.meaning})');
        }
      }
    } catch (e) {
      debugPrint('❌ 단어장 목록 조회 중 오류 발생: $e');
    }
  }
}
