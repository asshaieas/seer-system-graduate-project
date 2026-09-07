import 'package:flutter/material.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF071329),
        appBar: AppBar(
          backgroundColor: const Color(0xFF071329),
          title: const Text('ولي الأمر'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'مرحباً بك في تطبيق ولي الأمر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}