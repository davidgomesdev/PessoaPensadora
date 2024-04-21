import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Click on a text in the drawer should make it appear in the history',
          (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();

    var textFinder = find.text('A vida é terra e o vivê-la é lodo.');
    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(ListTile), matching: textFinder), findsOne);
  });
}
