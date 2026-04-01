import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/screen/home_screen.dart';
import 'package:pessoa_pensadora/ui/widget/coll_item_widget.dart';
import 'package:pessoa_pensadora/ui/widget/het_card_widget.dart';
import 'package:pessoa_pensadora/ui/widget/reader/text_reader.dart';
import 'package:pessoa_pensadora/ui/widget/text_row_widget.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Browse tab / home screen ──────────────────────────────────────────────

  testWidgets('Home Browse tab shows the 9 root category cards',
      (tester) async {
    await startApp(tester);

    const categoryNames = [
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

    for (var name in categoryNames) {
      await scrollUntilVisibleInBrowse(tester, find.text(name));
      expect(find.text(name), findsOne);
    }
  });

  testWidgets('Tapping a root category card navigates to its content screen',
      (tester) async {
    await startApp(tester);

    // Scroll to make Rubaiyat visible (it's the last card)
    final rubaiyatFinder = find.text('Rubaiyat');

    await scrollUntilVisibleInBrowse(tester, rubaiyatFinder);
    await tester.tap(rubaiyatFinder.first);
    await tester.pumpAndSettle();

    // CategoryScreen is now shown — at least the first text is visible
    expect(find.text('A vida é terra e o vivê-la é lodo.'), findsOne);
  });

  testWidgets(
      'Tapping a category with subcategories shows subcategory items',
      (tester) async {
    await startApp(tester);

    await tester.tap(find.text('Poemas de Alberto Caeiro'));
    await tester.pumpAndSettle();

    // Should show subcategory CollItemWidget items
    expect(find.byType(CollItemWidget), findsAtLeast(1));
  });

  testWidgets(
      'Tapping a subcategory navigates into it showing its texts',
      (tester) async {
    await startApp(tester);

    await tester.tap(find.text('Poemas de Alberto Caeiro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('O GUARDADOR DE REBANHOS'));
    await tester.pumpAndSettle();

    // Texts of "O GUARDADOR DE REBANHOS" are now visible
    expect(find.byType(TextRowWidget), findsAtLeast(1));
    expect(find.text('I - Eu nunca guardei rebanhos,'), findsOne);
  });

  testWidgets('Tapping a text in a category opens the reader with that text',
      (tester) async {
    await startApp(tester);

    // Scroll to make Rubaiyat visible (it's the last card)
    final rubaiyatFinder = find.text('Rubaiyat');
    await scrollUntilVisibleInBrowse(tester, rubaiyatFinder);
    await tester.tap(rubaiyatFinder.first);
    await tester.pumpAndSettle();

    final textFinder = find.text('A vida é terra e o vivê-la é lodo.');
    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    expect(
        find.descendant(
            of: find.byType(TextReader),
            matching: find.text('A vida é terra e o vivê-la é lodo.')),
        findsOne);
    expect(
        find.descendant(
            of: find.byType(TextReader),
            matching: find.textContaining('Em tudo quanto faças sê só tu,')),
        findsOne);
  });

  // ── Category text filter ──────────────────────────────────────────────────

  group('Text filter', () {
    final exampleTextFinder = find.text('A DIVINA INVEJA');

    testWidgets(
        'Filtering by a partial term shows matching texts',
        (tester) async {
      await startApp(tester);

      await scrollUntilVisibleInBrowse(tester, find.text('Livro do Desassossego'));
      await tester.tap(find.text('Livro do Desassossego'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'DiVina');
      await tester.pumpAndSettle();

      expect(exampleTextFinder, findsOne);
      expect(find.byType(TextRowWidget), findsAtLeast(2));
    });

    testWidgets(
        'Filtering by a unique term shows only that text',
        (tester) async {
      await startApp(tester);

      await scrollUntilVisibleInBrowse(tester, find.text('Livro do Desassossego'));
      await tester.tap(find.text('Livro do Desassossego'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'A DIVINA INVEJ');
      await tester.pumpAndSettle();

      expect(exampleTextFinder, findsOne);
      expect(find.byType(TextRowWidget), findsOne);
    });

    testWidgets(
        'Filtering by a non-existing term shows no text',
        (tester) async {
      await startApp(tester);

      await scrollUntilVisibleInBrowse(tester, find.text('Livro do Desassossego'));
      await tester.tap(find.text('Livro do Desassossego'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'wak2jios9');
      await tester.pumpAndSettle();

      expect(exampleTextFinder, findsNothing);
      expect(find.byType(TextRowWidget), findsNothing);
    });
  });

  // ── Sorting ───────────────────────────────────────────────────────────────

  group('Sorting', () {
    testWidgets(
        'Alphabetically sorted category shows texts in alphabetical order',
        (tester) async {
      await startApp(tester);

      await scrollUntilVisibleInBrowse(tester, find.text('Livro do Desassossego'));
      await tester.tap(find.text('Livro do Desassossego'));
      await tester.pumpAndSettle();

      final texts = getCategoryScreenTexts();

      final order = [
        texts.indexOf("... e do alto da majestade de todos os sonhos, "
            "ajudante de guarda-livros..."),
        texts.indexOf("... e tudo é uma doença incurável."),
        texts.indexOf("A DIVINA INVEJA"),
        texts.indexOf('A SOCIEDADE EM QUE EU VIVO'),
      ];

      expect(order.sorted((a, b) => a.compareTo(b)), order);
    });

    testWidgets(
        'Roman-numeral sorted category shows texts in numeral order',
        (tester) async {
      await startApp(tester);

      await scrollUntilVisibleInBrowse(tester, find.text('MENSAGEM'));
      await tester.tap(find.text('MENSAGEM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Segunda parte: MAR PORTUGUÊS'));
      await tester.pumpAndSettle();

      final texts = getCategoryScreenTexts();

      final order = [
        texts.indexOf('I. O INFANTE'),
        texts.indexOf('II. HORIZONTE'),
        texts.indexOf('III. PADRÃO'),
        texts.indexOf('IV. O MOSTRENGO'),
        texts.indexOf('V. EPITÁFIO DE BARTOLOMEU DIAS'),
        texts.indexOf('VI. OS COLOMBOS'),
        texts.indexOf('VII. OCIDENTE'),
        texts.indexOf('VIII. FERNÃO DE MAGALHÃES'),
        texts.indexOf('IX. ASCENSÃO DE VASCO DA GAMA'),
        texts.indexOf('X. MAR PORTUGUÊS'),
        texts.indexOf('XI. A ÚLTIMA NAU'),
        texts.indexOf('XII. PRECE'),
      ];

      expect(order.sorted((a, b) => a.compareTo(b)), order);
    });

    testWidgets(
        'Mixed roman + alphabetical category shows roman texts first',
        (tester) async {
      await startApp(tester);

      await tester.tap(find.text('Poemas de Alberto Caeiro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('O GUARDADOR DE REBANHOS'));
      await tester.pumpAndSettle();

      final texts = getCategoryScreenTexts();

      final order = [
        texts.indexOf('I - Eu nunca guardei rebanhos,'),
        texts.indexOf('II - O meu olhar é nítido como um girassol.'),
        texts.indexOf('VI - Pensar em Deus é desobedecer a Deus,'),
        texts.indexOf('IX - Sou um guardador de rebanhos.'),
      ];

      expect(order.sorted((a, b) => a.compareTo(b)), order);
    });

    testWidgets(
        'Portuguese-numeral sorted category shows texts in Portuguese numeral order',
        (tester) async {
      await startApp(tester);

      await scrollUntilVisibleInBrowse(tester, find.text('MENSAGEM'));
      await tester.tap(find.text('MENSAGEM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Primeira parte: BRASÃO'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('II - OS CASTELOS'));
      await tester.pumpAndSettle();

      final texts = getCategoryScreenTexts();

      final order = [
        texts.indexOf('Primeiro: ULISSES'),
        texts.indexOf('Segundo: VIRIATO'),
        texts.indexOf('Terceiro: O CONDE D. HENRIQUE'),
        texts.indexOf('Quarto: D. TAREJA'),
        texts.indexOf('Quinto: D. AFONSO HENRIQUES'),
        texts.indexOf('Sétimo (I): D. JOÃO O PRIMEIRO'),
        texts.indexOf('Sétimo (II): D. FILIPA DE LENCASTRE'),
      ];

      expect(order.sorted((a, b) => a.compareTo(b)), order);
    });
  });
}

