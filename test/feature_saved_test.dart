import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_bonito/ui/screen/saved_texts_screen.dart';
import 'package:pessoa_bonito/ui/widget/text_reader.dart';

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

    expect(find.byIcon(Icons.bookmark_outlined), findsOne);

    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    expect(
        find.descendant(
            of: find.widgetWithText(ExpansionTile, 'Rubaiyat'),
            matching: textFinder),
        findsOne);
  });

  testWidgets(
      'Saving a text of a subcategory should appear '
      'in the saved texts screen with the root category', (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.text('Poemas de Alberto Caeiro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('POEMAS INCONJUNTOS'));
    await tester.pumpAndSettle();

    var textFinder = find.text('A criança que pensa em fadas e acredita nas fadas');

    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_outline_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmark_outlined), findsOne);

    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    expect(
        find.descendant(
            of: find.widgetWithText(ExpansionTile, 'Poemas de Alberto Caeiro'),
            matching: textFinder),
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

    expect(find.byIcon(Icons.bookmark_outlined), findsOne);

    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    final tileFinder =
        find.ancestor(of: textFinder, matching: find.byType(Slidable));

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

    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    expect(tileFinder, findsNothing);
  });

  testWidgets(
      'Clicking on a saved text should make the saved reader screen show with it',
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

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    final reader = tester.widget<TextReader>(find.byType(TextReader));

    expect(reader.author, equals('Fernando Pessoa'));
    expect(reader.categoryTitle, equals('Rubaiyat'));
    expect(reader.title, equals('A vida é terra e o vivê-la é lodo.'));
    expect(reader.content, contains('Em tudo quanto faças sê só tu'));

    expect(textFinder, findsOne);
    expect(find.textContaining('Em tudo quanto faças sê só tu'), findsOne);
  });

  testWidgets(
      'Undoing an unsave of a text should NOT remove it from the saved texts screen',
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

    expect(find.byIcon(Icons.bookmark_outlined), findsOne);

    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    final tileFinder =
        find.ancestor(of: textFinder, matching: find.byType(Slidable));

    await tester.drag(tileFinder, const Offset(-500.0, 0));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete), findsOne);
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(textFinder, findsOne);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find
        .byWidgetPredicate((widget) => widget is ListTile && widget.selected));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmark_outlined), findsOne);

    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    expect(tileFinder, findsOne);
  });

  testWidgets(
      'Saving two texts of the same category should appear in the same group of the saved texts screen',
      (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();

    var firstTextFinder = find.text('A vida é terra e o vivê-la é lodo.');

    await tester.tap(firstTextFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_outline_outlined));
    await tester.pumpAndSettle();

    await openDrawer(tester);

    var secondTextFinder = find.text('Ao gozo segue a dor, e o gozo a esta.');

    await tester.tap(secondTextFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_outline_outlined));
    await tester.pumpAndSettle();

    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    expect(
        find.descendant(
            of: find.byType(SavedTextsScreen),
            matching: find.byType(ExpansionTile)),
        findsOne);
    expect(find.widgetWithText(ExpansionTile, 'Rubaiyat'), findsOne);
    expect(
        find.descendant(
            of: find.widgetWithText(ExpansionTile, 'Rubaiyat'),
            matching: firstTextFinder),
        findsOne);
    expect(
        find.descendant(
            of: find.widgetWithText(ExpansionTile, 'Rubaiyat'),
            matching: secondTextFinder),
        findsOne);
  });

  testWidgets(
      'Saving two texts of the different categories should appear in different groups of the saved texts screen',
      (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();

    var firstTextFinder = find.text('A vida é terra e o vivê-la é lodo.');

    await tester.tap(firstTextFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_outline_outlined));
    await tester.pumpAndSettle();

    await openDrawer(tester);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Livro do Desassossego'));
    await tester.pumpAndSettle();

    var secondTextFinder =
        find.text('Vivo sempre no presente. O futuro, não o conheço.');

    await tester.scrollUntilVisible(secondTextFinder, 300.0,
        scrollable: findScrollableTile(
            find.byKey(const PageStorageKey("drawer-list-view"))),
        maxScrolls: 500);

    await tester.tap(secondTextFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_outline_outlined));
    await tester.pumpAndSettle();

    await openDrawer(tester);

    await tester.tap(find.byIcon(Icons.bookmarks));
    await tester.pumpAndSettle();

    expect(
        find.descendant(
            of: find.byType(SavedTextsScreen),
            matching: find.byType(ExpansionTile)),
        findsNWidgets(2));
    expect(find.widgetWithText(ExpansionTile, 'Rubaiyat'), findsOne);
    expect(
        find.descendant(
            of: find.widgetWithText(ExpansionTile, 'Rubaiyat'),
            matching: firstTextFinder),
        findsOne);

    expect(
        find.widgetWithText(ExpansionTile, 'Livro do Desassossego'), findsOne);
    expect(
        find.descendant(
            of: find.widgetWithText(ExpansionTile, 'Livro do Desassossego'),
            matching: secondTextFinder),
        findsOne);
  });

  group('Expansion status', () {
    testWidgets(
        'When a text is saved with no other texts, it should be expanded',
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

      await tester.tap(find.byIcon(Icons.bookmarks));
      await tester.pumpAndSettle();

      expect(
          find.widgetWithIcon(
              ExpansionTile, Icons.arrow_drop_down_circle_outlined),
          findsOne);
      expect(
          find.widgetWithIcon(
              SliverAppBar, Icons.arrow_drop_down_circle_outlined),
          findsOne);
    });

    testWidgets(
        'When a text is expanded and its expansion button is pressed, it should become collapsed',
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

      await tester.tap(find.byIcon(Icons.bookmarks));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
          of: find.byType(ExpansionTile),
          matching: find.byIcon(Icons.arrow_drop_down_circle_outlined)));
      await tester.pumpAndSettle();

      expect(
          find.widgetWithIcon(
              ExpansionTile, Icons.arrow_drop_down_circle_rounded),
          findsOne);
      expect(textFinder, findsNothing);

      await tester.pageBack();
      await openDrawer(tester);
      await tester.tap(find.byIcon(Icons.bookmarks));
      await tester.pumpAndSettle();

      expect(
          find.widgetWithIcon(
              ExpansionTile, Icons.arrow_drop_down_circle_rounded),
          findsOne);
      expect(textFinder, findsNothing);
      expect(
          find.descendant(
              of: find.byType(SliverAppBar),
              matching: find.byIcon(Icons.arrow_drop_down_circle_outlined)),
          findsOne);
    });

    testWidgets(
        'When a text is collapsed and its expansion button is pressed, it should become expanded',
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

      await tester.tap(find.byIcon(Icons.bookmarks));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
          of: find.byType(ExpansionTile),
          matching: find.byIcon(Icons.arrow_drop_down_circle_outlined)));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
          of: find.byType(ExpansionTile),
          matching: find.byIcon(Icons.arrow_drop_down_circle_rounded)));
      await tester.pumpAndSettle();

      expect(
          find.widgetWithIcon(
              ExpansionTile, Icons.arrow_drop_down_circle_outlined),
          findsOne);
      expect(textFinder, findsOne);

      await tester.pageBack();
      await openDrawer(tester);
      await tester.tap(find.byIcon(Icons.bookmarks));
      await tester.pumpAndSettle();

      expect(
          find.widgetWithIcon(
              ExpansionTile, Icons.arrow_drop_down_circle_outlined),
          findsOne);
      expect(textFinder, findsOne);
      expect(
          find.widgetWithIcon(
              SliverAppBar, Icons.arrow_drop_down_circle_outlined),
          findsOne);
    });
  });
}
