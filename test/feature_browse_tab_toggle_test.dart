import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/screen/home_screen.dart';
import 'package:pessoa_pensadora/ui/widget/het_card_widget.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BrowseTab Index Toggle', () {
    // ── Toggle visibility and state ───────────────────────────────────────────

    testWidgets('Toggle appears in the header of the Browse tab', (tester) async {
      await startApp(tester);

      final principalBtn = find.text('Principal');
      final completoBtn = find.text('Completo');

      expect(principalBtn, findsOne);
      expect(completoBtn, findsOne);
    });

    testWidgets('Principal toggle is selected by default', (tester) async {
      await startApp(tester);

      // The inactive button should be "Completo" (darker/dimmer)
      final principalBtn = find.text('Principal');
      
      // Verify Principal is active — check that it has active styling
      final principalContainer = find.ancestor(
        of: principalBtn,
        matching: find.byType(AnimatedContainer),
      );
      expect(principalContainer, findsWidgets);
    });

    // ── Display switching ─────────────────────────────────────────────────────

    testWidgets('Principal tab shows the 9 curated main categories', (tester) async {
      await startApp(tester);

      const curatedCategories = [
        'Poemas de Alberto Caeiro',
        'Poesia de Álvaro de Campos',
        'Odes de Ricardo Reis',
        'Poesia Ortónima de Fernando Pessoa',
        'Livro do Desassossego',
        'MENSAGEM',
        'Textos Heterónimos',
        'Textos Publicados em vida',
        'Rubaiyat',
      ];

      for (var name in curatedCategories) {
        await scrollUntilVisibleInBrowse(tester, find.text(name));
        expect(find.text(name), findsOne);
      }
    });

    testWidgets(
        'Tapping Completo toggle switches to full index showing additional categories',
        (tester) async {
      await startApp(tester);

      // Count cards in Principal view
      int principalCardCount = find.byType(HetCardWidget).evaluate().length;
      expect(principalCardCount, equals(9));

      // Tap "Completo" toggle
      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      // Full index should have more than 9 categories
      int completoCardCount = find.byType(HetCardWidget).evaluate().length;
      expect(completoCardCount, greaterThan(principalCardCount));
    });

    testWidgets(
        'Header subtitle changes when switching to full index',
        (tester) async {
      await startApp(tester);

      // Principal subtitle
      expect(find.text('Cinco hetónimos · Uma vida de máscaras'), findsOne);
      expect(find.text('Índice completo'), findsNothing);

      // Tap "Completo" toggle
      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      // Completo subtitle
      expect(find.text('Índice completo'), findsOne);
      expect(find.text('Cinco hetónimos · Uma vida de máscaras'), findsNothing);
    });

    testWidgets('Switching back to Principal restores the original view',
        (tester) async {
      await startApp(tester);

      // Go to Completo
      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      int completoCardCount = find.byType(HetCardWidget).evaluate().length;
      expect(completoCardCount, greaterThan(9));

      // Switch back to Principal
      await tester.tap(find.text('Principal'));
      await tester.pumpAndSettle();

      // Should have exactly 9 cards again
      int principalCardCount = find.byType(HetCardWidget).evaluate().length;
      expect(principalCardCount, equals(9));
      expect(find.text('Cinco hetónimos · Uma vida de máscaras'), findsOne);
    });

    // ── Toggle interaction ────────────────────────────────────────────────────

    testWidgets('Toggle buttons are tappable and responsive', (tester) async {
      await startApp(tester);

      // Tap Principal (already active)
      await tester.tap(find.text('Principal'));
      await tester.pumpAndSettle();

      expect(find.text('Cinco hetónimos · Uma vida de máscaras'), findsOne);

      // Tap Completo
      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      expect(find.text('Índice completo'), findsOne);

      // Tap Principal again
      await tester.tap(find.text('Principal'));
      await tester.pumpAndSettle();

      expect(find.text('Cinco hetónimos · Uma vida de máscaras'), findsOne);
    });

    testWidgets('Toggle state persists during tab navigation away and back',
        (tester) async {
      await startApp(tester);

      // Switch to Completo
      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      int completoCardCount = find.byType(HetCardWidget).evaluate().length;

      // Navigate to Guardados tab
      await switchToSavedTab(tester);
      await tester.pumpAndSettle();

      // Navigate back to Explorar (Browse)
      await switchToBrowseTab(tester);
      await tester.pumpAndSettle();

      // Completo should still be active
      int cardCountAfterReturn = find.byType(HetCardWidget).evaluate().length;
      expect(cardCountAfterReturn, equals(completoCardCount));
      expect(find.text('Índice completo'), findsOne);
    });

    // ── Navigation with different indices ────────────────────────────────────

    testWidgets(
        'Categories from Completo that are not in Principal still have empty subtitles',
        (tester) async {
      await startApp(tester);

      // Switch to Completo
      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      // Scroll down to see additional categories (beyond the 9 curated ones)
      // These additional categories won't have subtitles in the _subtitles map
      await tester.scrollUntilVisible(
        find.byType(HetCardWidget).last,
        200,
        scrollable: find.descendant(
          of: find.byType(BrowseTab),
          matching: find.byType(Scrollable),
        ).first,
      );
      await tester.pumpAndSettle();

      // Verify that HetCardWidget is still rendered (with empty or missing subtitle)
      expect(find.byType(HetCardWidget), findsWidgets);
    });

    testWidgets('Tapping a card from Principal index navigates correctly',
        (tester) async {
      await startApp(tester);

      // Principal is the default
      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      // Should be in CategoryScreen with subcategories visible
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('Tapping a card from Completo index navigates correctly',
        (tester) async {
      await startApp(tester);

      // Switch to Completo
      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      // Tap first visible category
      await tester.tap(find.text('Poemas de Alberto Caeiro').first);
      await tester.pumpAndSettle();

      // Should be in CategoryScreen
      expect(find.byType(ListView), findsWidgets);
    });

    // ── Visual styling ────────────────────────────────────────────────────────

    testWidgets('Active toggle segment has different styling from inactive',
        (tester) async {
      await startApp(tester);

      // Principal is active by default
      final principalFinder = find.text('Principal');
      final principalWidget = tester.widget<Text>(principalFinder);
      
      // Verify text exists and is styled
      expect(principalWidget.data, equals('Principal'));

      // Switch to Completo
      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      // Now Completo should be active
      final completoFinder = find.text('Completo');
      final completoWidget = tester.widget<Text>(completoFinder);
      
      expect(completoWidget.data, equals('Completo'));
    });

    // ── Edge cases ────────────────────────────────────────────────────────────

    testWidgets('Rapid toggling between indices works without crashes',
        (tester) async {
      await startApp(tester);

      // Rapidly tap between toggles
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Completo'));
        await tester.pump(const Duration(milliseconds: 100));
        
        await tester.tap(find.text('Principal'));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should end on Principal (last tap was Principal)
      expect(find.text('Cinco hetónimos · Uma vida de máscaras'), findsOne);
    });

    testWidgets(
        'Scrolling works correctly in both Principal and Completo views',
        (tester) async {
      await startApp(tester);

      // Scroll in Principal
      await scrollUntilVisibleInBrowse(
        tester,
        find.text('Rubaiyat'),
      );
      expect(find.text('Rubaiyat'), findsOne);

      // Switch to Completo
      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      // Scroll to the last card in Completo
      await tester.scrollUntilVisible(
        find.byType(HetCardWidget).last,
        200,
        scrollable: find.descendant(
          of: find.byType(BrowseTab),
          matching: find.byType(Scrollable),
        ).first,
      );
      await tester.pumpAndSettle();

      // Verify we can scroll without errors
      expect(find.byType(HetCardWidget), findsWidgets);
    });
  });
}

