import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_bonito/ui/widget/text_reader.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Opening drawer should render root categories', (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    expect(
        find.widgetWithIcon(ListTile, Icons.subdirectory_arrow_right_rounded),
        findsExactly(9));
    expect(find.text('Poemas de Alberto Caeiro'), findsOneWidget);
    expect(find.text('Poesia de Álvaro de Campos'), findsOneWidget);
    expect(find.text('Odes de Ricardo Reis'), findsOneWidget);
    expect(find.text('Poesia Ortónima de Fernando Pessoa'), findsOneWidget);
    expect(find.text('Livro do Desassossego'), findsOneWidget);
    expect(find.text('MENSAGEM'), findsOneWidget);
    expect(find.text('Textos Heterónimos'), findsOneWidget);
    expect(find.text('Textos Publicados em vida'), findsOneWidget);
    expect(find.text('Rubaiyat'), findsOneWidget);
  });

  testWidgets('Clicking on a category should show its texts', (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();

    expect(find.text('A vida é terra e o vivê-la é lodo.'), findsOneWidget);

    // before scrolling to it
    expect(find.text('Vimos de nada e vamos para onde.'), findsNothing);

    await tester.scrollUntilVisible(
        find.text('Vimos de nada e vamos para onde.'), 500.0,
        scrollable: find.descendant(
            of: find.byKey(const PageStorageKey("drawer-list-view")),
            matching: find.byWidgetPredicate((w) => w is Scrollable)));
    expect(find.text('Vimos de nada e vamos para onde.'), findsOneWidget);
  });

  testWidgets(
      'Clicking on a category and then "Back" should go back to the index',
      (tester) async {
    await startApp(tester);
    await openDrawer(tester);

    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(
        find.widgetWithIcon(ListTile, Icons.subdirectory_arrow_right_rounded),
        findsExactly(9));
    expect(find.text('Poemas de Alberto Caeiro'), findsOneWidget);
    expect(find.text('Poesia de Álvaro de Campos'), findsOneWidget);
    expect(find.text('Odes de Ricardo Reis'), findsOneWidget);
    expect(find.text('Poesia Ortónima de Fernando Pessoa'), findsOneWidget);
    expect(find.text('Livro do Desassossego'), findsOneWidget);
    expect(find.text('MENSAGEM'), findsOneWidget);
    expect(find.text('Textos Heterónimos'), findsOneWidget);
    expect(find.text('Textos Publicados em vida'), findsOneWidget);
    expect(find.text('Rubaiyat'), findsOneWidget);
  });

  testWidgets('Click on a text should open the reader with that text', (tester) async {
    await startApp(tester);
    await openDrawer(tester);
    
    await tester.tap(find.text('Rubaiyat'));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('A vida é terra e o vivê-la é lodo.'));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(TextReader), matching: find.text("A vida é terra e o vivê-la é lodo.")), findsOne);
    expect(find.descendant(of: find.byType(TextReader), matching: find.textContaining("Em tudo quanto faças sê só tu,")), findsOne);
  });
}
