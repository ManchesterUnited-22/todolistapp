import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_app/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen renders key content', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('Serene Focus'), findsOneWidget);
    expect(find.text('ĐANG TẢI...'), findsOneWidget);
  });
}
