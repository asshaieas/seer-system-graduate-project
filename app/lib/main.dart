import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

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
      home: const LoginScreen(),
    );
  }
}