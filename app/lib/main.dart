import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SeerApp());
}

class SeerApp extends StatelessWidget {
  const SeerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سير',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD6A84F),
          brightness: Brightness.dark,
        ),

        textTheme: GoogleFonts.alexandriaTextTheme(ThemeData.dark().textTheme),

        primaryTextTheme: GoogleFonts.alexandriaTextTheme(
          ThemeData.dark().primaryTextTheme,
        ),

        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.alexandria(),
          hintStyle: GoogleFonts.alexandria(),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(
              GoogleFonts.alexandria(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(
              GoogleFonts.alexandria(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(
              GoogleFonts.alexandria(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),

      home: const LoginScreen(),

      // للرجوع للواجهة الأصلية:
      // home: const LoginScreen(),
    );
  }
}
