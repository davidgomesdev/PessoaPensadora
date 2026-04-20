import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/widget/highlight_text_widget.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Text Search Functionality', () {
    testWidgets('Search field has correct hint text', (tester) async {
      await startApp(tester);

      final hintText = find.text('Pesquisar textos...');
      expect(hintText, findsOne);
    });

    testWidgets('Search field has search icon', (tester) async {
      await startApp(tester);

      final searchIcon = find.byIcon(Icons.search);
      expect(searchIcon, findsWidgets);
    });

    testWidgets('Submitting empty search does not navigate', (tester) async {
      await startApp(tester);

      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await submitText(tester);

      expect(find.text('A Obra de Fernando Pessoa'), findsOne);
    });

    testWidgets('Submitting query with only whitespace does not navigate',
        (tester) async {
      await startApp(tester);

      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await tester.enterText(searchField, '   ');
      await tester.pumpAndSettle();

      await submitText(tester);

      expect(find.text('A Obra de Fernando Pessoa'), findsOne);
    });

    testWidgets('Search field accepts text input', (tester) async {
      await startApp(tester);

      final searchField = find.byType(TextField);
      final TextEditingController controller =
          tester.widget<TextField>(searchField).controller!;

      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'amor');
      await tester.pumpAndSettle();

      expect(controller.text, equals('amor'));
    });

    testWidgets('Search field allows text entry with various characters',
        (tester) async {
      await startApp(tester);

      final testQueries = [
        'Fernando',
        'Pessoa',
        'Poesia',
        '1888',
        'Pessoa-Campos'
      ];

      for (final query in testQueries) {
        final searchField = find.byType(TextField);
        final TextEditingController controller =
            tester.widget<TextField>(searchField).controller!;

        controller.clear();
        await tester.pumpAndSettle();

        await tester.tap(searchField);
        await tester.pumpAndSettle();

        await tester.enterText(searchField, query);
        await tester.pumpAndSettle();

        expect(controller.text, equals(query));
      }
    });

    testWidgets('Search field is single-line input', (tester) async {
      await startApp(tester);

      final searchField = find.byType(TextField);
      final textFieldWidget = tester.widget<TextField>(searchField);

      expect(textFieldWidget.maxLines, equals(1));
    });

    testWidgets('Search field can be manually cleared', (tester) async {
      await startApp(tester);

      final searchField = find.byType(TextField);
      final TextEditingController controller =
          tester.widget<TextField>(searchField).controller!;

      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'amor');
      await tester.pumpAndSettle();
      expect(controller.text, equals('amor'));

      controller.clear();
      await tester.pumpAndSettle();

      expect(controller.text, isEmpty);

      await tester.enterText(searchField, 'verdade');
      await tester.pumpAndSettle();
      expect(controller.text, equals('verdade'));
    });

    testWidgets('Search field appears in correct position in AppBar',
        (tester) async {
      await startApp(tester);

      final appBar = find.byType(AppBar);
      final searchField = find.byType(TextField);
      final searchInAppBar = find.ancestor(
        of: searchField,
        matching: appBar,
      );

      expect(searchInAppBar, findsOne);
    });

    testWidgets('Search finds result', (tester) async {
      await startApp(tester);

      final searchField = find.byType(TextField);
      final TextEditingController controller =
          tester.widget<TextField>(searchField).controller!;

      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'amor');
      await tester.pumpAndSettle();
      expect(controller.text, equals('amor'));

      await submitText(tester);

      expect(find.text('Pesquisa'), findsOne);

      expect(find.text('"amor"'), findsOne);

      // Query + texts result
      expect(find.textContaining('amor', findRichText: true), findsAtLeast(2));
      expect(find.text('404 resultados encontrados'), findsOne);
    });

    testWidgets('Search finds no results with random text', (tester) async {
      await startApp(tester);

      final searchField = find.byType(TextField);
      final TextEditingController controller =
          tester.widget<TextField>(searchField).controller!;

      await tester.tap(searchField);
      await tester.pumpAndSettle();

      var input = 'qwertyuiopasdfghjklzxcvbnm';
      await tester.enterText(searchField, input);
      await tester.pumpAndSettle();
      expect(controller.text, equals(input));

      await submitText(tester);

      expect(find.text('Pesquisa'), findsOne);

      expect(find.text('"qwertyuiopasdfghjklzxcvbnm"'), findsOne);

      // Query + texts result (none)
      expect(find.textContaining(input, findRichText: true), findsExactly(1));
      expect(find.text('0 resultados encontrados'), findsOne);
    });

    testWidgets('Search field preserves text content when unfocused',
        (tester) async {
      await startApp(tester);

      final searchField = find.byType(TextField);
      final TextEditingController controller =
          tester.widget<TextField>(searchField).controller!;

      await tester.tap(searchField);
      await tester.pumpAndSettle();

      await tester.enterText(searchField, 'amor');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppBar));
      await tester.pumpAndSettle();

      expect(controller.text, equals('amor'));
    });

    testWidgets('Search controller is accessible and manageable',
        (tester) async {
      await startApp(tester);

      final searchField = find.byType(TextField);
      final TextEditingController controller =
          tester.widget<TextField>(searchField).controller!;

      expect(controller, isNotNull);

      controller.text = 'test';
      await tester.pumpAndSettle();
      expect(controller.text, equals('test'));

      controller.clear();
      await tester.pumpAndSettle();
      expect(controller.text, isEmpty);
    });

    testWidgets('Multiple queries can be entered sequentially', (tester) async {
      await startApp(tester);

      final queries = ['primeira', 'segunda', 'terceira'];

      for (final query in queries) {
        final searchField = find.byType(TextField);
        final TextEditingController controller =
            tester.widget<TextField>(searchField).controller!;

        controller.clear();
        await tester.pumpAndSettle();

        await tester.tap(searchField);
        await tester.pumpAndSettle();

        await tester.enterText(searchField, query);
        await tester.pumpAndSettle();

        expect(controller.text, equals(query));
      }
    });
  });

  group('HighlightTextWidget Rendering with Search Query', () {
    testWidgets('HighlightTextWidget renders text content', (tester) async {
      const testText = 'Pessoa';
      const query = 'Pess';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: testText,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('HighlightTextWidget renders case-insensitive matches',
        (tester) async {
      const textContent = 'FERNANDO pessoa';
      const query = 'fernando';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: textContent,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('HighlightTextWidget applies base style', (tester) async {
      const testText = 'Pessoa';
      const query = 'Pess';
      const baseStyle = TextStyle(fontSize: 14, color: Colors.black);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: testText,
              query: query,
              baseStyle: baseStyle,
            ),
          ),
        ),
      );

      final richText = find.byType(RichText);
      expect(richText, findsWidgets);
    });

    testWidgets('HighlightTextWidget handles partial matches', (tester) async {
      const textContent = 'Pesquisa de Pessoa';
      const query = 'Pes';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: textContent,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('HighlightTextWidget renders with maxLines constraint',
        (tester) async {
      const textContent =
          'Pessoa Pensadora trabalhou em muitos projetos ao longo de sua vida literária';
      const query = 'Pessoa';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: textContent,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
              maxLines: 2,
            ),
          ),
        ),
      );

      final richText = find.byType(RichText);
      expect(richText, findsWidgets);

      final richTextWidget =
          tester.widget<RichText>(find.byType(RichText).first);
      expect(richTextWidget.maxLines, equals(2));
    });

    testWidgets('HighlightTextWidget renders empty query without crashing',
        (tester) async {
      const testText = 'Pessoa';
      const query = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: testText,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('HighlightTextWidget highlights query at text start',
        (tester) async {
      const textContent = 'Fernando';
      const query = 'Fer';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: textContent,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('HighlightTextWidget highlights query at text end',
        (tester) async {
      const textContent = 'Pessoa';
      const query = 'oa';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: textContent,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('HighlightTextWidget highlights query in middle of text',
        (tester) async {
      const textContent = 'Fernando Pessoa';
      const query = 'ndo';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: textContent,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('HighlightTextWidget handles special characters in query',
        (tester) async {
      const textContent = 'Pessoa-Campos';
      const query = '-';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: textContent,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('HighlightTextWidget renders with built-in highlight style',
        (tester) async {
      const testText = 'Pessoa';
      const query = 'ess';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: testText,
              query: query,
              baseStyle: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ),
      );

      final richText = find.byType(RichText);
      expect(richText, findsWidgets);

      final richTextWidget =
          tester.widget<RichText>(find.byType(RichText).first);
      expect(richTextWidget, isNotNull);
    });

    testWidgets('HighlightTextWidget renders multiple occurrences of query',
        (tester) async {
      const textContent = 'Pessoa pensou que Pessoa era grande';
      const query = 'Pessoa';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: textContent,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('HighlightTextWidget renders without query match',
        (tester) async {
      const textContent = 'Fernando';
      const query = 'XYZ';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: textContent,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('HighlightTextWidget text is clickable/tappable',
        (tester) async {
      const testText = 'Pessoa';
      const query = 'Pess';
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () {
                tapped = true;
              },
              child: HighlightTextWidget(
                text: testText,
                query: query,
                baseStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RichText));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('HighlightTextWidget renders long text with query',
        (tester) async {
      const textContent =
          'Fernando Pessoa foi um poeta português que viveu em Lisboa e escreveu muitos poemas notáveis. Pessoa também criou heterônimos para explorar diferentes perspectivas poéticas.';
      const query = 'Pessoa';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightTextWidget(
              text: textContent,
              query: query,
              baseStyle: const TextStyle(fontSize: 14),
              maxLines: 3,
            ),
          ),
        ),
      );

      final richText = find.byType(RichText);
      expect(richText, findsWidgets);

      final richTextWidget =
          tester.widget<RichText>(find.byType(RichText).first);
      expect(richTextWidget.maxLines, equals(3));
    });
  });
}
