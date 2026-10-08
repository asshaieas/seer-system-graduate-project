import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SeerAiService {
  static const _endpoint =
      'https://us-central1-seer-17007.cloudfunctions.net/seerAiSupport';

  Future<String> ask(String question) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': question}),
    );

    debugPrint('SEER AI status: ${response.statusCode}');
    debugPrint('SEER AI body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'AI service error: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['output'] as String;
  }
}