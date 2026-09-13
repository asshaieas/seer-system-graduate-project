import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('SEER app opens login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SeerApp());

    expect(find.text('مرحباً بك في SEER'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsNWidgets(2));
  });
}