import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/screen/home_screen.dart';
import 'package:pessoa_pensadora/ui/widget/category_card_widget.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BrowseTab Index Toggle', () {
    testWidgets('Toggle appears in the header of the Browse tab', (tester) async {
      await startApp(tester);

      final principalBtn = find.text('Principal');
      final completoBtn = find.text('Completo');

      expect(principalBtn, findsOne);
      expect(completoBtn, findsOne);
    });

    testWidgets('Principal toggle is selected by default', (tester) async {
      await startApp(tester);

      final principalBtn = find.text('Principal');

      final principalContainer = find.ancestor(
        of: principalBtn,
        matching: find.byType(AnimatedContainer),
      );
      expect(principalContainer, findsWidgets);
    });

    testWidgets('Principal tab shows the 9 curated main categories', (tester) async {
      await startApp(tester);

      await expectAllMainCategories(tester);
    });

    testWidgets(
        'Tapping Completo toggle switches to full index showing additional categories',
        (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      await expectAllMainCategories(tester);

      var text = find.text('Textos Filosóficos');
      await scrollUntilVisibleInBrowse(tester, text);
      expect(text, findsOne);
    });

    testWidgets('Switching back to Principal restores the original view',
        (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      var text = find.text('Textos Filosóficos');
      await scrollUntilVisibleInBrowse(tester, text);
      expect(text, findsOne);

      await tester.tap(find.text('Principal'));
      await tester.pumpAndSettle();

      scrollToEnd(tester, BrowseTab);
      await tester.pumpAndSettle();

      expect(text, findsNothing);
    });

    testWidgets('Toggle state persists during tab navigation away and back',
        (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      int completoCardCount = find.byType(CategoryCardWidget).evaluate().length;

      await switchToSavedTab(tester);
      await tester.pumpAndSettle();

      await switchToBrowseTab(tester);
      await tester.pumpAndSettle();

      int cardCountAfterReturn = find.byType(CategoryCardWidget).evaluate().length;
      expect(cardCountAfterReturn, equals(completoCardCount));
    });

    testWidgets(
        'Categories from Completo that are not in Principal still have empty subtitles',
        (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(CategoryCardWidget).last,
        200,
        scrollable: find.descendant(
          of: find.byType(BrowseTab),
          matching: find.byType(Scrollable),
        ).first,
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryCardWidget), findsWidgets);
    });

    testWidgets('Tapping a card from Principal index navigates correctly',
        (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('Tapping a card from Completo index navigates correctly',
        (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Poemas de Alberto Caeiro').first);
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('Active toggle segment has different styling from inactive',
        (tester) async {
      await startApp(tester);

      final principalFinder = find.text('Principal');
      final principalWidget = tester.widget<Text>(principalFinder);

      expect(principalWidget.data, equals('Principal'));

      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      final completoFinder = find.text('Completo');
      final completoWidget = tester.widget<Text>(completoFinder);

      expect(completoWidget.data, equals('Completo'));
    });

    testWidgets('Rapid toggling between indices works without crashes',
        (tester) async {
      await startApp(tester);

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Completo'));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text('Principal'));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();
    });

    testWidgets(
        'Scrolling works correctly in both Principal and Completo views',
        (tester) async {
      await startApp(tester);

      await scrollUntilVisibleInBrowse(
        tester,
        find.text('Rubaiyat'),
      );
      expect(find.text('Rubaiyat'), findsOne);

      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(CategoryCardWidget).last,
        200,
        scrollable: find.descendant(
          of: find.byType(BrowseTab),
          matching: find.byType(Scrollable),
        ).first,
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryCardWidget), findsWidgets);
    });
  });
}

Future<void> expectAllMainCategories(WidgetTester tester) async {
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
}

void scrollToEnd(WidgetTester tester, Type parentType) {
  final scrollableFinder = find.descendant(
    of: find.byType(parentType),
    matching: find.byType(Scrollable),
  ).first;
  final scrollable = tester.state<ScrollableState>(scrollableFinder);
  final controller = scrollable.widget.controller!;

  controller.jumpTo(controller.positions.first.maxScrollExtent);
}
