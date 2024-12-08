import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  final VoidCallback onClose; // onClose 콜백 추가

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
  ]; // 초기 메시지
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      // 사용자 메시지 추가
      messages.add({'role': 'user', 'message': userMessage});
      // 챗봇 응답 추가 (임시)
      messages.add({
        'role': 'bot',
        'message':
            '기한 이익 상실이란, 대출받은 사람이 일정 조건을 위반했을 때 잔여 대출금을 즉시 상환해야 하는 상황입니다.',
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(), // 왼쪽 여백
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
            onPressed: widget.onClose, // onClose 콜백 호출
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser) // 봇 메시지일 때만 아이콘 표시
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
                          color: isUser
                              ? Colors.blue[100]
                              : Colors.grey[200], // 색상
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['message']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUser ? Colors.black : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
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
