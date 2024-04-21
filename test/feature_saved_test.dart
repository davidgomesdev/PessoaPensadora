import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Saved texts screen with no saved texts should show no texts',
      (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('Saving a text should make it appear in the saved texts screen',
      (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();

    var textFinder = find.text('A vida é terra e o vivê-la é lodo.');

    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_outline_outlined));
    await tester.pumpAndSettle();

    await openDrawer(tester);

    expect(find.byIcon(Icons.bookmark_outlined), findsOne);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    expect(
        find.descendant(
            of: find.widgetWithText(ExpansionTile, 'Rubaiyat'),
            matching: find.text('A vida é terra e o vivê-la é lodo.')),
        findsOne);
  });

  testWidgets(
      'Unsaving a text should make it disappear from the saved texts screen',
      (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();

    var textFinder = find.text('A vida é terra e o vivê-la é lodo.');

    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_outline_outlined));
    await tester.pumpAndSettle();

    await openDrawer(tester);

    expect(find.byIcon(Icons.bookmark_outlined), findsOne);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    final tileFinder = find.ancestor(
        of: find.text('A vida é terra e o vivê-la é lodo.'),
        matching: find.byType(Slidable));

    await tester.drag(tileFinder, const Offset(-500.0, 0));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete), findsOne);
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    await tester.drag(
        find.text('Removido dos textos marcados'), const Offset(0.0, 50.0));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find
        .byWidgetPredicate((widget) => widget is ListTile && widget.selected));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmark_outline_outlined), findsOne);
  });
}
