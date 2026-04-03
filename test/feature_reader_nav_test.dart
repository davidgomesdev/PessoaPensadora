import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/widget/reader/text_reader.dart';
import 'package:pessoa_pensadora/ui/widget/text_row_widget.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const text1 = 'A abelha que, voando, freme sobre';
  const text2 = 'A cada qual, como a estatura, é dada';
  const text3 = 'A flor que és, não a que dás, eu quero. [2]';

  const textLast = 'Vou dormir, dormir, dormir,';

  Future<void> openOdesText(WidgetTester tester, String textTitle) async {
    await tester.tap(find.text('Odes de Ricardo Reis'));
    await tester.pumpAndSettle();
    final textFinder = find.text(textTitle);
    await scrollUntilVisibleInCategory(tester, textFinder);
    expect(textFinder, findsOne);
    await tester.tap(textFinder);
    await tester.pumpAndSettle();
  }

  Future<void> scrollUntilVisibleInReader(
      WidgetTester tester,
      Finder finder, {
        double scrollDelta = 200,
      }) async {
    final scrollable = find.descendant(
      of: find.byType(TextReader),
      matching: find.byType(Scrollable),
    );
    expect(scrollable, findsAtLeast(1));
    await tester.scrollUntilVisible(
        finder,
        scrollDelta,
        scrollable: scrollable.first
    );
  }

  Future<Finder> prevBtn(WidgetTester tester, [String? prevTitle]) async {
    final prevBtn = find.text('← ${prevTitle ?? "Anterior"}');

    await scrollUntilVisibleInReader(tester, prevBtn);

    expect(prevBtn, findsOne);
    return prevBtn;
  }

  Future<Finder> nextBtn(WidgetTester tester, [String? nextTitle]) async {
    final nextBtn = find.text('${nextTitle ?? "Seguinte"} →');

    await scrollUntilVisibleInReader(tester, nextBtn);

    expect(nextBtn, findsOne);
    return nextBtn;
  }

  String readerTitle(WidgetTester tester) =>
      tester.widget<TextReader>(find.byType(TextReader)).title;

  group('prev button', () {
    testWidgets('tapping prev navigates to the previous text', (tester) async {
      await startApp(tester);
      await openOdesText(tester, text2);

      await tester.tap(await prevBtn(tester, text1));
      await tester.pumpAndSettle();

      expect(readerTitle(tester), equals(text1));
    });

    testWidgets('tapping prev when on the first text does nothing',
        (tester) async {
      await startApp(tester);
      await openOdesText(tester, text1);

      await tester.tap(await prevBtn(tester));
      await tester.pumpAndSettle();

      expect(readerTitle(tester), equals(text1));
    });

    testWidgets(
        'prev, prev, back — Get.off() keeps a single reader on the stack '
        'so back returns to the category screen', (tester) async {
      await startApp(tester);
      await openOdesText(tester, text3);

      await tester.tap(await prevBtn(tester, text2));
      await tester.pumpAndSettle();
      expect(readerTitle(tester), equals(text2));

      await tester.tap(await prevBtn(tester, text1));
      await tester.pumpAndSettle();
      expect(readerTitle(tester), equals(text1));

      await hitCurrentBackButton(tester);

      expect(find.byType(TextReader), findsNothing);
      expect(find.byType(TextRowWidget), findsAtLeast(1));
    });
  });

  group('next button', () {
    testWidgets('tapping next navigates to the next text', (tester) async {
      await startApp(tester);
      await openOdesText(tester, text1);

      await tester.tap(await nextBtn(tester, text2));
      await tester.pumpAndSettle();

      expect(readerTitle(tester), equals(text2));
    });

    testWidgets('tapping next when on the last text does nothing',
        (tester) async {
      await startApp(tester);
      await openOdesText(tester, textLast);

      await tester.tap(await nextBtn(tester));
      await tester.pumpAndSettle();

      expect(readerTitle(tester), equals(textLast));
    });

    testWidgets(
        'next, next, back — Get.off() keeps a single reader on the stack '
        'so back returns to the category screen', (tester) async {
      await startApp(tester);
      await openOdesText(tester, text1);

      await tester.tap(await nextBtn(tester, text2));

      await tester.pumpAndSettle();
      expect(readerTitle(tester), equals(text2));

      await tester.tap(await nextBtn(tester, text3));
      await tester.pumpAndSettle();
      expect(readerTitle(tester), equals(text3));

      await hitCurrentBackButton(tester);

      expect(find.byType(TextReader), findsNothing);
      expect(find.byType(TextRowWidget), findsAtLeast(1));
    });
  });
}

Future<void> hitCurrentBackButton(WidgetTester tester) async {
  Finder backButton = find.byTooltip('Back');
  expect(backButton, findsAny);
  await tester.tap(backButton.last);
  await tester.pumpAndSettle();
}
