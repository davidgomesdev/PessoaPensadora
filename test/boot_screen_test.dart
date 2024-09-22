import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/screen/boot_screen.dart';
import 'package:pessoa_pensadora/ui/screen/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Boot screen should show splash', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BootScreen()));

    expect(find.byType(SplashScreen), findsOne);
  });
}