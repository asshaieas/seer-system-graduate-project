import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/screens/auth/login_screen_ali.dart';

void main() {
  testWidgets('SEER parent login renders the designed actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreenAli()),
    );

    expect(find.text('مرحبًا بك'), findsOneWidget);
    expect(find.text('إرسال رمز التحقق'), findsOneWidget);
    expect(find.text('الدخول بالبريد الإلكتروني'), findsOneWidget);
    expect(find.text('الدخول عبر نفاذ'), findsOneWidget);
  });

  testWidgets('invalid phone number is shown inline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreenAli()),
    );

    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pump();

    expect(
      find.text('رقم الجوال غير صحيح. أدخل ١٠ أرقام تبدأ بـ 05.'),
      findsOneWidget,
    );
    expect(find.text('تصحيح رقم الجوال'), findsOneWidget);
  });
}
