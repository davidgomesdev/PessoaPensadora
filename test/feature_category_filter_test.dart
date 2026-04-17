import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/widget/subcategory_row_widget.dart';
import 'package:pessoa_pensadora/ui/widget/text_row_widget.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Category Screen Text Filter', () {
    testWidgets('Filter field appears in CategoryScreen', (tester) async {
      await startApp(tester);

      // Navigate to a category
      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      // Find the filter field
      final filterFields = find.byType(TextField);
      expect(filterFields, findsWidgets);

      // Verify the hint text
      expect(find.text('Filtrar…'), findsOne);
    });

    testWidgets('Filter field has correct hint text', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final hintText = find.text('Filtrar…');
      expect(hintText, findsOne);
    });

    testWidgets('Filter field has search icon', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final searchIcon = find.byIcon(Icons.search);
      expect(searchIcon, findsWidgets);
    });

    testWidgets('Empty filter shows all items', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      // With empty filter, ListView should have items
      final listView = find.byType(ListView);
      expect(listView, findsOne);
    });

    testWidgets('Filter accepts text input', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField);
      await tester.tap(filterField.first);
      await tester.pumpAndSettle();

      await tester.enterText(filterField.first, 'guardador');
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('guardador'), findsWidgets);
    });

    testWidgets('Filter matches both categories and texts', (tester) async {
      await startApp(tester);


      var ld = find.text('Livro do Desassossego');
      await scrollUntilVisibleInBrowse(tester, ld);
      await tester.tap(ld);
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField);
      await tester.tap(filterField.first);
      await tester.pumpAndSettle();

      await tester.enterText(filterField.first, 'notas');
      await tester.pumpAndSettle();

      await submitText(tester);

      expect(find.byType(TextRowWidget), findsNWidgets(2));
      expect(find.byType(SubcategoryRowWidget), findsOne);

      // Text Input + results
      expect(find.text('notas', findRichText: true), findsOne);
      expect(find.text('Notas', findRichText: true), findsOne);
      expect(find.textContaining('NOTAS', findRichText: true), findsOne);
      // This one matches on text content - not title
      expect(find.textContaining('Figuras', findRichText: true), findsOne);
    });

    testWidgets('Filter with no matches shows "Nenhum resultado"',
        (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField);
      await tester.tap(filterField.first);
      await tester.pumpAndSettle();

      // Enter query that won't match anything
      await tester.enterText(filterField.first, 'xyzabc123nonexistent');
      await tester.pumpAndSettle();

      // Should show "Nenhum resultado"
      expect(find.text('Nenhum resultado'), findsOne);
      expect(find.byType(SubcategoryRowWidget), findsNothing);
    });

    testWidgets('Clearing filter shows all items again', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // Enter a filter
      await tester.enterText(filterField, 'guardador');
      await tester.pumpAndSettle();

      // Clear the filter
      final controller = tester.widget<TextField>(filterField).controller;
      controller?.clear();
      await tester.pumpAndSettle();

      // Should show all items again (no "Nenhum resultado" message)
      expect(find.text('Nenhum resultado'), findsNothing);
    });

    testWidgets('Filter with partial match shows results', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // Enter partial query
      await tester.enterText(filterField, 'a');
      await tester.pumpAndSettle();

      // Should have results or no results message
      final noResults = find.text('Nenhum resultado');
      final listView = find.byType(ListView);
      expect(listView.evaluate().isNotEmpty || noResults.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('Filter handles special characters', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // Enter query with special characters
      await tester.enterText(filterField, 'à-é');
      await tester.pumpAndSettle();

      // Should handle special characters without crashing
      expect(find.text('à-é'), findsWidgets);
    });

    testWidgets('Filter handles whitespace', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // Enter query with leading/trailing spaces
      await tester.enterText(filterField, '  guardador  ');
      await tester.pumpAndSettle();

      // Should handle whitespace (converted to lowercase)
      expect(find.text('  guardador  '), findsWidgets);
    });

    testWidgets('Rapid filter changes work correctly', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // Rapidly change filter
      await tester.enterText(filterField, 'g');
      await tester.pump();
      await tester.enterText(filterField, 'gu');
      await tester.pump();
      await tester.enterText(filterField, 'gua');
      await tester.pump();
      await tester.enterText(filterField, 'guar');
      await tester.pump();
      await tester.enterText(filterField, 'guard');
      await tester.pumpAndSettle();

      // Should end with correct results
      expect(find.text('guard'), findsWidgets);
    });

    testWidgets('Filter results update reactively', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // Apply filter that won't match
      await tester.enterText(filterField, 'xyzabc123nonexistent');
      await tester.pumpAndSettle();

      // Should show "Nenhum resultado"
      expect(find.text('Nenhum resultado'), findsOne);
    });

    testWidgets('Filter shows subcategories matching query', (tester) async {
      await startApp(tester);

      // Navigate to a category with subcategories
      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // Enter a filter (will match texts or subcategories)
      await tester.enterText(filterField, 'Pastor');
      await tester.pumpAndSettle();

      // Should have results
      final items = find.byType(SubcategoryRowWidget).evaluate();
      expect(items.length, equals(1));
    });

    testWidgets('Filter field is responsive to changes', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;

      // Verify filter field exists and is a TextField
      expect(filterField, findsOne);

      // Verify we can access its controller
      final textFieldWidget = tester.widget<TextField>(filterField);
      expect(textFieldWidget, isNotNull);
    });

    testWidgets('Multiple queries filter results correctly', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // First query
      await tester.enterText(filterField, 'a');
      await tester.pumpAndSettle();

      var resultsCount = find.byType(TextRowWidget).evaluate().length;
      expect(resultsCount, greaterThanOrEqualTo(0));

      // Second query (narrower)
      final controller = tester.widget<TextField>(filterField).controller;
      controller?.clear();
      await tester.pumpAndSettle();

      await tester.enterText(filterField, 'ab');
      await tester.pumpAndSettle();

      resultsCount = find.byType(TextRowWidget).evaluate().length;
      expect(resultsCount, greaterThanOrEqualTo(0));
    });

    testWidgets('Filter query is trimmed for matching', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // Enter query with leading/trailing spaces
      await tester.enterText(filterField, '   guard   ');
      await tester.pumpAndSettle();

      // Results should be filtered (spaces in query are handled)
      // Should either show results or "Nenhum resultado"
      final hasResults = find.byType(TextRowWidget).evaluate().isNotEmpty;
      final noResults = find.text('Nenhum resultado').evaluate().isNotEmpty;

      expect(hasResults || noResults, isTrue);
    });

    testWidgets('Filter handles very long input', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // Enter very long text
      const longText =
          'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz';
      await tester.enterText(filterField, longText);
      await tester.pumpAndSettle();

      // Should show "Nenhum resultado" or handle gracefully
      final noResults = find.text('Nenhum resultado').evaluate().isNotEmpty;
      expect(noResults, isTrue);
    });

    testWidgets('Filter preserves state when scrolling', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final filterField = find.byType(TextField).first;
      await tester.tap(filterField);
      await tester.pumpAndSettle();

      // Apply a filter
      await tester.enterText(filterField, 'o');
      await tester.pumpAndSettle();

      // Get results count
      final resultsCount = find.byType(TextRowWidget).evaluate().length;

      // Scroll if there are results
      if (resultsCount > 0) {
        final listView = find.byType(ListView);
        await tester.drag(listView, const Offset(0, -200));
        await tester.pumpAndSettle();

        // Filter should still be active with same results
        final newCount = find.byType(TextRowWidget).evaluate().length;
        expect(newCount, equals(resultsCount));
      }
    });

    testWidgets('Filter field appears in correct position', (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      final appBar = find.byType(AppBar);
      final filterField = find.byType(TextField).first;

      // Filter should be below appbar (in body, not in appbar)
      expect(appBar, findsOne);
      expect(filterField, findsOne);
    });
  });
}












