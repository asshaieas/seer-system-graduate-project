import 'package:flutter/material.dart';

import 'screens/auth/role_selection_screen.dart';

void main() {
  runApp(const SeerApp());
}

class SeerApp extends StatelessWidget {
  const SeerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Canva Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD6A84F),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}