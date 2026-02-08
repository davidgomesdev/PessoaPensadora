import 'package:collection/collection.dart';
import 'package:flag/flag.dart';
import 'package:flag/flag_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/widget/text_selection_drawer_list_view.dart';
import 'package:pessoa_pensadora/ui/widget/reader/text_reader.dart';
import 'package:pessoa_pensadora/ui/widget/text_selection_drawer.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Changing language to english should change buttons but not category titles',
      (tester) async {
    await startApp(tester);

    expect(find.text('Índice'), findsAtLeast(1));

    // The drawer auto opens in the start of the app, so we need to close it
    // to hit the button to change the language
    await tester.tap(find.text('Pessoa Pensadora'), warnIfMissed: false);
    await tester.pumpAndSettle();

    final changeLanguageButton = find.ancestor(of: find.byTooltip('Mudar idioma'), matching: find.byType(IconButton));

    expect(changeLanguageButton, findsOne);

    await tester.tap(changeLanguageButton);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.text('Index'), findsAtLeast(1));

    await openDrawer(tester);

    expect(find.byTooltip('Main reading'), findsOne);
    expect(find.byTooltip('Bookmarked texts'), findsOne);
    expect(find.byTooltip('History'), findsOne);

    assertIndex();
  });

  testWidgets(
      'Changing language to english then to portuguese should have buttons in portuguese',
      (tester) async {
    await startApp(tester);

    expect(find.text('Índice'), findsAtLeast(1));

    // The drawer auto opens in the start of the app, so we need to close it
    // to hit the button to change the language
    await tester.tap(find.text('Pessoa Pensadora'), warnIfMissed: false);
    await tester.pumpAndSettle();

    final changeLanguageButton = find.ancestor(of: find.byTooltip('Mudar idioma'), matching: find.byType(IconButton));

    expect(changeLanguageButton, findsOne);

    await tester.tap(changeLanguageButton);
    await tester.pumpAndSettle();

    expect(find.text('Index'), findsAtLeast(1));

    await tester.tap(changeLanguageButton);
    await tester.pumpAndSettle();

    expect(find.text('Índice'), findsAtLeast(1));

    await openDrawer(tester);

    expect(find.byTooltip('Leitura principal'), findsOne);
    expect(find.byTooltip('Textos marcados'), findsOne);
    expect(find.byTooltip('Histórico'), findsOne);

    assertIndex();
  });
}

void assertIndex() {
  expect(find.widgetWithIcon(ListTile, Icons.subdirectory_arrow_right_rounded),
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
}
