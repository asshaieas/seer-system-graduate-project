import 'package:flutter/material.dart';

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

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF071329),
        appBar: AppBar(
          backgroundColor: const Color(0xFF071329),
          title: const Text(
            'سِير',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.directions_bus,
                  size: 80,
                  color: Color(0xFFD6A84F),
                ),
                const SizedBox(height: 24),
                const Text(
                  'نظام سير للحافلات المدرسية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'اختر نوع المستخدم للمتابعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 280,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ParentHomeScreen(),
                          ),
                        );
                      },
                    icon: const Icon(Icons.family_restroom),
                    label: const Text(
                      'ولي الأمر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 280,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DriverHomeScreen(),
    ),
  );
},
                    icon: const Icon(Icons.drive_eta),
                    label: const Text(
                      'السائق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
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

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF071329),
        appBar: AppBar(
          backgroundColor: const Color(0xFF071329),
          title: const Text('السائق'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'مرحباً بك في تطبيق السائق',
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