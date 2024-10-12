import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Click on a text in the drawer should make it appear in the history',
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

    expect(find.descendant(of: find.byType(ListTile), matching: textFinder),
        findsOne);
  });

  testWidgets(
      'When switching to reading type main after clicking on a text in the drawer, the text should appear in the history',
      (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await openDrawer(tester);

    await switchReadingTypeToFull(tester);

    final rootCategoryFinder =
        find.widgetWithText(ListTile, "Textos Filosóficos");

    await dragDrawerUntilVisible(tester, rootCategoryFinder);
    await tester.pumpAndSettle();

    await tester.tap(rootCategoryFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filósofos'));
    await tester.pumpAndSettle();

    final textFinder = find.text('CHANGE');

    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    await openDrawer(tester);

    await hitBackDrawerButton(tester);
    await hitBackDrawerButton(tester);

    await switchReadingTypeToMain(tester);

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(ListTile), matching: textFinder),
        findsOne);
  });
}
