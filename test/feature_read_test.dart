import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_bonito/ui/widget/text_selection_drawer.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Long pressing an unread text should mark it as read',
          (tester) async {
        await startApp(tester);
        await openDrawer(tester);

        await tester.tap(find.text('Rubaiyat'));
        await tester.pumpAndSettle();

        var textFinder = find.text('A vida é terra e o vivê-la é lodo.');
        var tile = tester.firstWidget<ListTile>(
            find.ancestor(of: textFinder, matching: find.byType(ListTile)));

        expect(tile.textColor, equals(Colors.white));
        expect(tile.selectedColor, equals(Colors.white));
        expect(tile.selected, equals(false));
        expect(find.text('0/41'), findsOneWidget);

        await tester.longPress(textFinder);
        await tester.pumpAndSettle();

        tile = tester.firstWidget<ListTile>(
            find.ancestor(of: textFinder, matching: find.byType(ListTile)));

        expect(tile.textColor, equals(Colors.white60));
        expect(tile.selectedColor, equals(Colors.white60));
        expect(tile.selected, equals(false));
        expect(find.text('1/41'), findsOneWidget);
      });

  testWidgets('Long pressing a read text should mark it as unread',
          (tester) async {
        await startApp(tester);
        await openDrawer(tester);

        await tester.tap(find.text('Rubaiyat'));
        await tester.pumpAndSettle();

        final textFinder = find.text('A vida é terra e o vivê-la é lodo.');

        var tile = tester.firstWidget<ListTile>(
            find.ancestor(of: textFinder, matching: find.byType(ListTile)));

        expect(tile.textColor, equals(Colors.white));
        expect(tile.selectedColor, equals(Colors.white));
        expect(tile.selected, equals(false));
        expect(find.text('0/41'), findsOneWidget);

        await tester.longPress(textFinder);
        await tester.pumpAndSettle();

        await tester.longPress(textFinder);
        await tester.pumpAndSettle();

        tile = tester.firstWidget<ListTile>(
            find.ancestor(of: textFinder, matching: find.byType(ListTile)));

        expect(tile.textColor, equals(Colors.white));
        expect(tile.selectedColor, equals(Colors.white));
        expect(tile.selected, equals(false));
        expect(find.text('0/41'), findsOneWidget);
      });

  testWidgets('When filtering for unread texts, only the unread texts should appear',
          (tester) async {
        await startApp(tester);
        await openDrawer(tester);

        await tester.tap(find.text('Rubaiyat'));
        await tester.pumpAndSettle();

        final textFinder = find.text('A vida é terra e o vivê-la é lodo.');

        await tester.longPress(textFinder);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(SearchReadFilter.all.icon));
        await tester.pumpAndSettle();

        expect(textFinder, findsNothing);
      });

  testWidgets('When filtering for read texts, only the the read text should appear',
          (tester) async {
        await startApp(tester);
        await openDrawer(tester);

        await tester.tap(find.text('Rubaiyat'));
        await tester.pumpAndSettle();

        final textFinder = find.text('A vida é terra e o vivê-la é lodo.');

        await tester.longPress(textFinder);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(SearchReadFilter.all.icon));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(SearchReadFilter.unread.icon));
        await tester.pumpAndSettle();

        expect(textFinder, findsOne);
        expect(find.byIcon(Icons.text_snippet_rounded), findsOne);
      });

  testWidgets('When filtering for all texts, all texts should appear',
          (tester) async {
        await startApp(tester);
        await openDrawer(tester);

        await tester.tap(find.text('Rubaiyat'));
        await tester.pumpAndSettle();

        final textFinder = find.text('A vida é terra e o vivê-la é lodo.');

        await tester.longPress(textFinder);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(SearchReadFilter.all.icon));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(SearchReadFilter.unread.icon));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(SearchReadFilter.read.icon));
        await tester.pumpAndSettle();

        expect(textFinder, findsOne);
      });
}
