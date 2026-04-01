import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/widget/group_header_widget.dart';
import 'package:pessoa_pensadora/ui/widget/reader/text_reader.dart';
import 'package:pessoa_pensadora/ui/widget/s_item_widget.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── helpers ──────────────────────────────────────────────────────────────

  /// Navigate from the home Browse tab into [category] → [text] and open the
  /// reader.  Returns the Finder for the text title.
  Future<Finder> openText(WidgetTester tester, {
    required String category,
    String? subcategory,
    required String text,
  }) async {
    await tester.tap(find.text(category));
    await tester.pumpAndSettle();
    if (subcategory != null) {
      await tester.tap(find.text(subcategory));
      await tester.pumpAndSettle();
    }
    final textFinder = find.text(text);
    await tester.tap(textFinder);
    await tester.pumpAndSettle();
    return textFinder;
  }

  /// Press back [n] times to unwind [n] routes.
  Future<void> goBack(WidgetTester tester, [int n = 1]) async {
    for (var i = 0; i < n; i++) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  }

  // ── tests ─────────────────────────────────────────────────────────────────

  testWidgets('Saved tab with no saved texts shows empty message',
          (tester) async {
        await startApp(tester);
        await switchToSavedTab(tester);

        expect(find.text('Nenhum texto guardado :('), findsOne);
        expect(find.byType(SItemWidget), findsNothing);
      });

  testWidgets('Saving a text makes it appear in the Saved tab',
          (tester) async {
        await startApp(tester);

        final textFinder = await openText(
          tester,
          category: 'Odes de Ricardo Reis',
          text: 'A flor que és, não a que dás, eu quero. [2]',
        );

        await saveCurrentText(tester);

        // Go back to home (1 CategoryScreen + reader = 2 pops)
        await goBack(tester, 2);
        await switchToSavedTab(tester);

        expect(
            find.descendant(of: find.byType(SItemWidget), matching: textFinder),
            findsOne);
      });

  testWidgets(
      'Saving a text from a subcategory appears under the root category header',
          (tester) async {
        await startApp(tester);

        final textFinder = await openText(
          tester,
          category: 'Poemas de Alberto Caeiro',
          subcategory: 'POEMAS INCONJUNTOS',
          text: 'A criança que pensa em fadas e acredita nas fadas',
        );

        await saveCurrentText(tester);
        await goBack(tester, 3);
        await switchToSavedTab(tester);

        // Header for root category (toUpperCase)
        expect(
            find.descendant(
                of: find.byType(GroupHeaderWidget),
                matching: find.text('POEMAS DE ALBERTO CAEIRO')),
            findsOne);
        expect(
            find.descendant(of: find.byType(SItemWidget), matching: textFinder),
            findsOne);
      });

  testWidgets('Removing a saved text removes it from the Saved tab',
          (tester) async {
        await startApp(tester);

        final textFinder = await openText(
          tester,
          category: 'Odes de Ricardo Reis',
          text: 'A flor que és, não a que dás, eu quero. [2]',
        );

        await saveCurrentText(tester);
        await goBack(tester, 2);
        await switchToSavedTab(tester);

        expect(
            find.descendant(of: find.byType(SItemWidget), matching: textFinder),
            findsOne);

        await tester.tap(find.descendant(
            of: find.byType(SItemWidget), matching: find.byIcon(Icons.close)));
        await tester.pumpAndSettle();

        // Verify the text was removed, retrying with pump until it succeeds or times out.
        // This handles async Hive operations that may take time to complete.
        await expectEventuallyWithPump(
          tester,
          () {
            expect(
                find.descendant(of: find.byType(SItemWidget), matching: textFinder),
                findsNothing);
            expect(find.text('Nenhum texto guardado :('), findsOne);
          },
          timeout: const Duration(seconds: 5),
        );
      });

  testWidgets('Tapping a saved text opens the reader with correct content',
          (tester) async {
        await startApp(tester);

        final textFinder = await openText(
          tester,
          category: 'Odes de Ricardo Reis',
          text: 'A flor que és, não a que dás, eu quero. [2]',
        );

        await saveCurrentText(tester);
        await goBack(tester, 2);
        await switchToSavedTab(tester);

        await tester.tap(
            find.ancestor(of: textFinder, matching: find.byType(SItemWidget)));
        await tester.pumpAndSettle();

        final reader = tester.widget<TextReader>(find.byType(TextReader));

        expect(reader.author, equals('Ricardo Reis'));
        expect(reader.categoryTitle, equals('Odes de Ricardo Reis'));
        expect(reader.title,
            equals('A flor que és, não a que dás, eu quero. [2]'));
        expect(reader.content, contains('Porque me negas o que te não peço?'));

        expect(
            find.descendant(
                of: find.byType(TextReader),
                matching: find.textContaining(
                    'Porque me negas o que te não peço?')),
            findsOne);
      });

  testWidgets(
      'Saving two texts from the same category shows them under one group header',
          (tester) async {
        await startApp(tester);

        debugDumpRenderTree();

        final firstTextFinder = await openText(
          tester,
          category: 'Odes de Ricardo Reis',
          text: 'A flor que és, não a que dás, eu quero. [2]',
        );
        await saveCurrentText(tester);
        await goBack(tester, 1); // back to CategoryScreen

        final secondTextFinder = find.text(
            'A cada qual, como a estatura, é dada');
        await tester.tap(secondTextFinder);
        await tester.pumpAndSettle();
        await saveCurrentText(tester);
        await goBack(tester, 2); // back to home

        await switchToSavedTab(tester);

        // Exactly one group header (Odes de Ricardo Reis)
        expect(find.byType(GroupHeaderWidget), findsOne);
        expect(
            find.descendant(
                of: find.byType(GroupHeaderWidget),
                matching: find.text('ODES DE RICARDO REIS')),
            findsOne);
        expect(
            find.descendant(
                of: find.byType(SItemWidget), matching: firstTextFinder),
            findsOne);
        expect(
            find.descendant(
                of: find.byType(SItemWidget), matching: secondTextFinder),
            findsOne);
      });

  testWidgets(
      'Saving texts from different categories shows them under separate group headers',
          (tester) async {
        await startApp(tester);

        // Save first text from Odes de Ricardo Reis
        final firstTextFinder = await openText(
          tester,
          category: 'Odes de Ricardo Reis',
          text: 'A flor que és, não a que dás, eu quero. [2]',
        );
        await saveCurrentText(tester);
        await goBack(tester, 2);
        await tester.pumpAndSettle();

        var secondCategoryFinder = find.text('Livro do Desassossego');

        await scrollUntilVisibleInBrowse(tester, secondCategoryFinder);
        await tester.tap(secondCategoryFinder);
        await tester.pumpAndSettle();

        final secondTextFinder =
        find.text('Vivo sempre no presente. O futuro, não o conheço.');
        await scrollUntilVisibleInCategory(tester, secondTextFinder);
        await tester.pumpAndSettle();
        await tester.tap(secondTextFinder);
        await tester.pumpAndSettle();
        await saveCurrentText(tester);
        await goBack(tester, 2);

        await switchToSavedTab(tester);

        // Two group headers
        expect(find.byType(GroupHeaderWidget), findsNWidgets(2));
        expect(
            find.descendant(
                of: find.byType(GroupHeaderWidget),
                matching: find.text('ODES DE RICARDO REIS')),
            findsOne);
        expect(
            find.descendant(
                of: find.byType(GroupHeaderWidget),
                matching: find.text('LIVRO DO DESASSOSSEGO')),
            findsOne);
        expect(
            find.descendant(
                of: find.byType(SItemWidget), matching: firstTextFinder),
            findsOne);
        expect(
            find.descendant(
                of: find.byType(SItemWidget), matching: secondTextFinder),
            findsOne);
      });
}
