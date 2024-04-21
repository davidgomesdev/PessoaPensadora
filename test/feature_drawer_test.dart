import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/ui/routes.dart';
import 'package:pessoa_bonito/ui/screen/base_screen.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Opening drawer should render root categories', (tester) async {
    await startApp(tester);

    final ScaffoldState state = tester.firstState(find.byType(Scaffold));

    state.openDrawer();

    await tester.pumpAndSettle();

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
}
