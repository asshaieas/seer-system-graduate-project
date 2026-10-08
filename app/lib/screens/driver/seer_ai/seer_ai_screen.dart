import 'package:flutter/material.dart';

import 'services/seer_ai_service.dart';
import 'widgets/seer_ai_welcome.dart';

class SeerAiScreen extends StatelessWidget {
  const SeerAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SeerAiService();

    return SeerAiWelcome(
      service: service,
    );
  }
}