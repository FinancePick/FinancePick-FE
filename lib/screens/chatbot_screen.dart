import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotScreen extends StatefulWidget {
  final VoidCallback onClose;

  const ChatbotScreen({super.key, required this.onClose});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> messages = [
    {
      'role': 'bot',
      'message':
          '안녕하세요! 😊\n저는 도우미 사전입니다.\n궁금한 경제 용어나 주식 관련 용어가 있다면 저에게 물어보세요!\n\n예를 들어:\n- "EPS가 뭐야?"\n- "테마주란?"\n- "PER의 의미 알려줘"'
    },
  ];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  final String _apiKey =
      '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';

  Future<void> _sendToChatGPT(String userMessage) async {
    const String apiUrl = "https://api.openai.com/v1/chat/completions";

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": userMessage},
          ],
          "max_tokens": 2000,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final botMessage = data['choices'][0]['message']['content'];

        setState(() {
          messages.add({'role': 'bot', 'message': botMessage.trim()});
        });
      } else {
        setState(() {
          messages.add({
            'role': 'bot',
            'message': '오류가 발생했습니다. 다시 시도해주세요.',
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          'role': 'bot',
          'message': '인터넷 연결을 확인해주세요.',
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage() {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'message': userMessage});
    });

    _controller.clear();
    _sendToChatGPT(userMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(),
        title: const Text(
          '도우미 사전',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: widget.onClose,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['role'] == 'user';

                return Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isUser)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['message']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'NotoSansKR',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
