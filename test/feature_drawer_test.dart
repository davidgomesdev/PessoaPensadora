import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/widget/text_selection_drawer_list_view.dart';
import 'package:pessoa_pensadora/ui/widget/reader/text_reader.dart';
import 'package:pessoa_pensadora/ui/widget/text_selection_drawer.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Opening drawer should render root categories', (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    expect(
        find.widgetWithIcon(ListTile, Icons.subdirectory_arrow_right_rounded),
        findsExactly(9));
    expect(find.text('Poemas de Alberto Caeiro'), findsOne);
    expect(find.text('Poesia de Álvaro de Campos'), findsOne);
    expect(find.text('Odes de Ricardo Reis'), findsOne);
    expect(find.text('Poesia Ortónima de Fernando Pessoa'), findsOne);
    expect(find.text('Livro do Desassossego'), findsOne);
    expect(find.text('MENSAGEM'), findsOne);
    expect(find.text('Textos Heterónimos'), findsOne);
    expect(find.text('Textos Publicados em vida'), findsOne);
    expect(find.text('Rubaiyat'), findsOne);
  });

  testWidgets('Clicking on a category should show its texts', (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();

    expect(find.text('0/41'), findsOne);

    expect(find.text('A vida é terra e o vivê-la é lodo.'), findsOne);

    // before scrolling to it
    var textFinder = find.text('Vimos de nada e vamos para onde.');
    expect(textFinder, findsNothing);

    await dragDrawerUntilVisible(tester, textFinder);
    expect(textFinder, findsOne);
  });

  testWidgets('Click on a text should open the reader with that text',
      (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();

    var textFinder = find.text('A vida é terra e o vivê-la é lodo.');
    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    expect(
        find.descendant(
            of: find.byType(TextReader),
            matching: find.text("A vida é terra e o vivê-la é lodo.")),
        findsOne);
    expect(
        find.descendant(
            of: find.byType(TextReader),
            matching: find.textContaining("Em tudo quanto faças sê só tu,")),
        findsOne);
  });

  testWidgets('Clicking on a text should mark it selected', (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();

    var textFinder = find.text('A vida é terra e o vivê-la é lodo.');
    var tile = tester.firstWidget<ListTile>(
        find.ancestor(of: textFinder, matching: find.byType(ListTile)));

    expect(tile.selected, equals(false));

    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    await openDrawer(tester);

    tile = tester.firstWidget<ListTile>(
        find.ancestor(of: textFinder, matching: find.byType(ListTile)));

    expect(tile.selected, equals(true));
  });

  group('Reading type', () {
    group('In main reading', () {
      testWidgets(
          'After clicking on the reading type button, all categories should appear',
          (tester) async {
        await startApp(tester);
        await openDrawer(tester);

        expect(
            find.widgetWithIcon(
                ListTile, Icons.subdirectory_arrow_right_rounded),
            findsExactly(9));
        expect(find.text('Poemas de Alberto Caeiro'), findsOne);
        expect(find.text('Poesia de Álvaro de Campos'), findsOne);
        expect(find.text('Odes de Ricardo Reis'), findsOne);
        expect(find.text('Poesia Ortónima de Fernando Pessoa'), findsOne);
        expect(find.text('Livro do Desassossego'), findsOne);
        expect(find.text('MENSAGEM'), findsOne);
        expect(find.text('Textos Heterónimos'), findsOne);
        expect(find.text('Textos Publicados em vida'), findsOne);
        expect(find.text('Rubaiyat'), findsOne);

        await switchReadingTypeToFull(tester);

        expect(
            find.widgetWithIcon(
                ListTile, Icons.subdirectory_arrow_right_rounded,
                skipOffstage: false),
            findsAtLeast(10));
      });

      testWidgets(
          'After clicking on a category and then "Back" it should go back to the main index',
          (tester) async {
        await startApp(tester);
        await openDrawer(tester);

        await tester.tap(find.text('Rubaiyat'));
        await tester.pumpAndSettle();

        await hitBackDrawerButton(tester);

        expect(
            find.widgetWithIcon(
                ListTile, Icons.subdirectory_arrow_right_rounded),
            findsExactly(9));
        expect(find.text('Poemas de Alberto Caeiro'), findsOne);
        expect(find.text('Poesia de Álvaro de Campos'), findsOne);
        expect(find.text('Odes de Ricardo Reis'), findsOne);
        expect(find.text('Poesia Ortónima de Fernando Pessoa'), findsOne);
        expect(find.text('Livro do Desassossego'), findsOne);
        expect(find.text('MENSAGEM'), findsOne);
        expect(find.text('Textos Heterónimos'), findsOne);
        expect(find.text('Textos Publicados em vida'), findsOne);
        expect(find.text('Rubaiyat'), findsOne);
      });

      testWidgets(
          'When viewing a text of an extra index category, that extra index category should not appear',
          (tester) async {
        await startApp(tester);
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
        await tester.tap(find.text('CHANGE'));
        await tester.pumpAndSettle();

        await openDrawer(tester);

        await hitBackDrawerButton(tester);
        await hitBackDrawerButton(tester);

        await tester.scrollUntilVisible(rootCategoryFinder, 50,
            scrollable: find.descendant(
                of: find.byKey(const PageStorageKey("drawer-list-view")),
                matching: find.byWidgetPredicate((w) => w is Scrollable)));

        await switchReadingTypeToMain(tester);

        expect(
            find.widgetWithIcon(
                ListTile, Icons.subdirectory_arrow_right_rounded),
            findsExactly(9));

        expect(rootCategoryFinder, findsNothing);
      });
    });

    group('In full reading', () {
      testWidgets(
          'After clicking on a category and then "Back" it should go back to the full index',
          (tester) async {
        await startApp(tester);
        await openDrawer(tester);

        await switchReadingTypeToFull(tester);

        await dragDrawerUntilVisible(
          tester,
          find.text('Textos Filosóficos'),
        );
        await tester.tap(find.text('Textos Filosóficos'));
        await tester.pumpAndSettle();

        await hitBackDrawerButton(tester);

        expect(
            find.widgetWithIcon(
                ListTile, Icons.subdirectory_arrow_right_rounded),
            findsAtLeast(10));
        expect(find.text('Poemas de Alberto Caeiro'), findsOne);
        expect(find.text('Poesia de Álvaro de Campos'), findsOne);
        expect(find.text('Odes de Ricardo Reis'), findsOne);
        expect(find.text('Poesia Ortónima de Fernando Pessoa'), findsOne);
        expect(find.text('Livro do Desassossego'), findsOne);
        expect(find.text('MENSAGEM'), findsOne);
        expect(find.text('Textos Heterónimos'), findsOne);
        expect(find.text('Textos Publicados em vida'), findsOne);
        expect(find.text('Rubaiyat'), findsOne);
        expect(find.text('Textos Filosóficos', skipOffstage: false), findsOne);
      });

      testWidgets(
          'After clicking on the reading type button, only the main categories should appear',
          (tester) async {
        await startApp(tester);
        await openDrawer(tester);

        expect(
            find.widgetWithIcon(
                ListTile, Icons.subdirectory_arrow_right_rounded),
            findsExactly(9));

        await switchReadingTypeToFull(tester);

        expect(
            find.widgetWithIcon(
                ListTile, Icons.subdirectory_arrow_right_rounded),
            findsAtLeast(10));

        await switchReadingTypeToMain(tester);

        expect(
            find.widgetWithIcon(
                ListTile, Icons.subdirectory_arrow_right_rounded),
            findsExactly(9));
        expect(find.text('Poemas de Alberto Caeiro'), findsOne);
        expect(find.text('Poesia de Álvaro de Campos'), findsOne);
        expect(find.text('Odes de Ricardo Reis'), findsOne);
        expect(find.text('Poesia Ortónima de Fernando Pessoa'), findsOne);
        expect(find.text('Livro do Desassossego'), findsOne);
        expect(find.text('MENSAGEM'), findsOne);
        expect(find.text('Textos Heterónimos'), findsOne);
        expect(find.text('Textos Publicados em vida'), findsOne);
        expect(find.text('Rubaiyat'), findsOne);
      });

      testWidgets(
          'When viewing a text of an extra index category, that extra index category should be highlighted',
          (tester) async {
        await startApp(tester);
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
        await tester.tap(find.text('CHANGE'));
        await tester.pumpAndSettle();

        await openDrawer(tester);

        await hitBackDrawerButton(tester);
        await hitBackDrawerButton(tester);

        await dragDrawerUntilVisible(tester, rootCategoryFinder);
        final categoryButtonWidget =
            rootCategoryFinder.evaluate().first.widget as ListTile;

        expect(categoryButtonWidget.selected, isTrue);
      });
    });
  });

  group('Read and read filter', () {
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
      expect(find.text('0/41'), findsOne);

      await tester.longPress(textFinder);
      await tester.pumpAndSettle();

      tile = tester.firstWidget<ListTile>(
          find.ancestor(of: textFinder, matching: find.byType(ListTile)));

      expect(tile.textColor, equals(Colors.white60));
      expect(tile.selectedColor, equals(Colors.white60));
      expect(tile.selected, equals(false));
      expect(find.text('1/41'), findsOne);
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
      expect(find.text('0/41'), findsOne);

      await tester.longPress(textFinder);
      await tester.pumpAndSettle();

      await tester.longPress(textFinder);
      await tester.pumpAndSettle();

      tile = tester.firstWidget<ListTile>(
          find.ancestor(of: textFinder, matching: find.byType(ListTile)));

      expect(tile.textColor, equals(Colors.white));
      expect(tile.selectedColor, equals(Colors.white));
      expect(tile.selected, equals(false));
      expect(find.text('0/41'), findsOne);
    });

    testWidgets(
        'When filtering for unread texts, only the unread texts should appear',
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

    testWidgets(
        'When filtering for read texts, only the the read text should appear',
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
  });

  group('Text filter', () {
    final exampleTextFinder = find.text('A DIVINA INVEJA');

    testWidgets(
        'When searching a term of an existing text and others, that text and others should appear',
        (tester) async {
      await startApp(tester);
      await openDrawer(tester);

      await tester.tap(find.text('Livro do Desassossego'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'DiVina');
      await tester.pumpAndSettle();

      expect(exampleTextFinder, findsOne);
      expect(find.byIcon(Icons.text_snippet_rounded), findsAtLeast(2));
      expect(
          find.byIcon(Icons.subdirectory_arrow_right_rounded), findsExactly(3));
    });

    testWidgets(
        'When searching a term of one existing text only, only that text should appear',
        (tester) async {
      await startApp(tester);
      await openDrawer(tester);

      await tester.tap(find.text('Livro do Desassossego'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'A DIVINA INVEJ');
      await tester.pumpAndSettle();

      expect(exampleTextFinder, findsOne);
      expect(find.byIcon(Icons.text_snippet_rounded), findsOne);
      expect(
          find.byIcon(Icons.subdirectory_arrow_right_rounded), findsExactly(3));
    });

    testWidgets(
        'When searching a term of a non-existing text, no text should appear',
        (tester) async {
      await startApp(tester);
      await openDrawer(tester);

      await tester.tap(find.text('Livro do Desassossego'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'wak2jios9');
      await tester.pumpAndSettle();

      expect(exampleTextFinder, findsNothing);
      expect(find.byIcon(Icons.text_snippet_rounded), findsNothing);
      expect(
          find.byIcon(Icons.subdirectory_arrow_right_rounded), findsExactly(3));
    });
  });

  group('Sorting', () {
    testWidgets(
        'When entering on a category with no special sorting, the texts should be sorted alphabetically',
        (tester) async {
      await startApp(tester);
      await openDrawer(tester);

      await tester.tap(find.text('Livro do Desassossego'));
      await tester.pumpAndSettle();

      List<String?> texts = getDrawerTexts();

      final order = [
        texts.indexOf("... e do alto da majestade de todos os sonhos, "
            "ajudante de guarda-livros..."),
        texts.indexOf("... e tudo é uma doença incurável."),
        texts.indexOf("A DIVINA INVEJA"),
        texts.indexOf('A SOCIEDADE EM QUE EU VIVO')
      ];

      expect(order.sorted((a, b) => a.compareTo(b)), order);
    });

    testWidgets(
        'When entering on a category with roman numeral sorting, the texts should be sorted by their roman numeral order',
        (tester) async {
      await startApp(tester);
      await openDrawer(tester);

      await tester.tap(find.text('MENSAGEM'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Segunda parte: MAR PORTUGUÊS'));
      await tester.pumpAndSettle();

      List<String?> texts = getDrawerTexts();

      List<int> order = [
        texts.indexOf("I. O INFANTE"),
        texts.indexOf("II. HORIZONTE"),
        texts.indexOf("III. PADRÃO"),
        texts.indexOf("IV. O MOSTRENGO"),
        texts.indexOf("V. EPITÁFIO DE BARTOLOMEU DIAS"),
        texts.indexOf("VI. OS COLOMBOS"),
        texts.indexOf("VII. OCIDENTE"),
        texts.indexOf("VIII. FERNÃO DE MAGALHÃES"),
        texts.indexOf("IX. ASCENSÃO DE VASCO DA GAMA"),
        texts.indexOf("X. MAR PORTUGUÊS"),
        texts.indexOf("XI. A ÚLTIMA NAU"),
        texts.indexOf("XII. PRECE"),
      ];

      expect(order.sorted((a, b) => a.compareTo(b)), order);
    });

    testWidgets(
        'When entering on a category with both roman numeral sorting and alphabetical, the texts should be sorted first by their roman numeral order then alphabetically',
        (tester) async {
      await startApp(tester);
      await openDrawer(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('O GUARDADOR DE REBANHOS'));
      await tester.pumpAndSettle();

      List<String?> texts = getDrawerTexts();

      // not bothering to check for the alphabetical order
      List<int> order = [
        texts.indexOf("I - Eu nunca guardei rebanhos,"),
        texts.indexOf("II - O meu olhar é nítido como um girassol."),
        texts.indexOf("VI - Pensar em Deus é desobedecer a Deus,"),
        texts.indexOf("IX - Sou um guardador de rebanhos."),
      ];

      expect(order.sorted((a, b) => a.compareTo(b)), order);
    });

    testWidgets(
        'When entering on a category with Portuguese numeral sorting and alphabetical, the texts should be sorted first by their Portuguese numeral order then alphabetically',
        (tester) async {
      await startApp(tester);
      await openDrawer(tester);

      await tester.tap(find.text('MENSAGEM'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Primeira parte: BRASÃO'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('II - OS CASTELOS'));
      await tester.pumpAndSettle();

      List<String?> texts = getDrawerTexts();

      // not bothering to check for the alphabetical order
      List<int> order = [
        texts.indexOf("Primeiro: ULISSES"),
        texts.indexOf("Segundo: VIRIATO"),
        texts.indexOf("Terceiro: O CONDE D. HENRIQUE"),
        texts.indexOf("Quarto: D. TAREJA"),
        texts.indexOf("Quinto: D. AFONSO HENRIQUES"),
        texts.indexOf("Sétimo (I): D. JOÃO O PRIMEIRO"),
        texts.indexOf("Sétimo (II): D. FILIPA DE LENCASTRE"),
      ];

      expect(order.sorted((a, b) => a.compareTo(b)), order);
    });
  });
}

List<String?> getDrawerTexts() {
  final texts = find
      .descendant(
          of: find.byType(DrawerTextTile, skipOffstage: false),
          matching: find.byType(Text, skipOffstage: false),
          skipOffstage: false)
      .evaluate()
      .map((text) => (text.widget as Text).data)
      .toList();
  return texts;
}
