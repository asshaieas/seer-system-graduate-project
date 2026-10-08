import 'package:flutter/material.dart';

import '../models/seer_ai_message.dart';
import '../services/seer_ai_service.dart';
import 'seer_ai_input.dart';
import 'seer_ai_message_bubble.dart';

class SeerAiWelcome extends StatefulWidget {
  final SeerAiService service;

  const SeerAiWelcome({
    super.key,
    required this.service,
  });

  @override
  State<SeerAiWelcome> createState() => _SeerAiWelcomeState();
}

class _SeerAiWelcomeState extends State<SeerAiWelcome> {
  final _controller = TextEditingController();
  final List<SeerAiMessage> _messages = [];
  bool _loading = false;

  final _suggestedQuestions = [
    'كيف أبدأ الرحلة؟',
    'ماذا يعني أن عدد الصعود لا يساوي عدد النزول؟',
    'كيف أعرف الطلاب الغائبين؟',
    'كيف أُسجّل طالبًا غير موجود في قائمة الرحلة، إذا ركب الحافلة لمرة واحدة ولا يملك بطاقة RFID/NFC خاصة به؟',
    'كيف يعمل RFID؟',
  ];

  Future<void> _askAi() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _loading) return;

    setState(() {
      _messages.add(
        SeerAiMessage(text: question, isUser: true),
      );
      _controller.clear();
      _loading = true;
    });

    try {
      final answer = await widget.service.ask(question);

      if (!mounted) return;

      setState(() {
        _messages.add(
          SeerAiMessage(text: answer, isUser: false),
        );
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          const SeerAiMessage(
            text: 'تعذر الاتصال بمساعد SEER حالياً.',
            isUser: false,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _selectQuestion(String question) {
    _controller.text = question;
    _askAi();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'مساعد SEER',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اسأل عن كيفية استخدام نظام SEER',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _messages.isEmpty
                ? ListView(
              children: [
                const Text(
                  'أسئلة مقترحة',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ..._suggestedQuestions.map(
                      (question) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      onPressed:
                      _loading
                          ? null
                          : () => _selectQuestion(question),
                      child: Text(
                        question,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            )
                : ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message =
                _messages[_messages.length - 1 - index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SeerAiMessageBubble(
                    message: message,
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('جاري الاتصال بمساعد SEER...'),
                ],
              ),
            ),
          SeerAiInput(
            controller: _controller,
            loading: _loading,
            onSend: _askAi,
          ),
        ],
      ),
    );
  }
}