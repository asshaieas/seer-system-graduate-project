import 'package:flutter/material.dart';

class SeerAiInput extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSend;

  const SeerAiInput({
    super.key,
    required this.controller,
    required this.loading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textDirection: TextDirection.rtl,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'اكتب سؤالك هنا...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: loading ? null : onSend,
          icon: const Icon(Icons.send),
          tooltip: 'إرسال',
        ),
      ],
    );
  }
}