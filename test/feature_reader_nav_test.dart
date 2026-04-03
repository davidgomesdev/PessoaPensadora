import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/widget/reader/text_reader.dart';
import 'package:pessoa_pensadora/ui/widget/text_row_widget.dart';

import 'utils.dart';

// TODO: fix the tests
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── text constants ────────────────────────────────────────────────────────
  //
  // These three are the first entries in "Odes de Ricardo Reis" in JSON
  // insertion order, which is the order the reader uses for prev/next
  // navigation (store.texts is a LinkedHashMap keyed in insertion order).
  // For the Odes category the JSON order happens to match the alphabetical
  // display order for the A-prefixed texts, so opening any of them from the
  // category screen gives the expected prev/next.
  const text1 = 'A abelha que, voando, freme sobre';       // index 0 — no prev
  const text2 = 'A cada qual, como a estatura, é dada';    // index 1
  const text3 = 'A flor que és, não a que dás, eu quero. [2]'; // index 2

  // Last text in JSON insertion order for the direct Odes texts (the V-group
  // in the JSON is not in strict alphabetical order, so the display order and
  // the nav order diverge there; "Vou dormir…" is the final JSON entry).
  const textLast = 'Vou dormir, dormir, dormir,';          // last — no next

  // ── helpers ───────────────────────────────────────────────────────────────

  /// Open the "Odes de Ricardo Reis" category and tap [textTitle].
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

  /// Finder for the prev nav button. When [prevTitle] is null the button is
  /// disabled and its label reads "← Anterior".
  Future<Finder> prevBtn(WidgetTester tester, [String? prevTitle]) async {
    final prevBtn = find.text('← ${prevTitle ?? "Anterior"}');

    await scrollUntilVisibleInReader(tester, prevBtn);

    expect(prevBtn, findsOne);
    return prevBtn;
  }

  /// Finder for the next nav button. When [nextTitle] is null the button is
  /// disabled and its label reads "Seguinte →".
  Future<Finder> nextBtn(WidgetTester tester, [String? nextTitle]) async {
    final nextBtn = find.text('${nextTitle ?? "Seguinte"} →');

    await scrollUntilVisibleInReader(tester, nextBtn);

    expect(nextBtn, findsOne);
    return nextBtn;
  }

  /// The title currently shown inside the TextReader widget.
  String readerTitle(WidgetTester tester) =>
      tester.widget<TextReader>(find.byType(TextReader)).title;

  // ── prev button ───────────────────────────────────────────────────────────

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

      // button is disabled — label shows "← Anterior"
      await tester.tap(await prevBtn(tester));
      await tester.pumpAndSettle();

      // still on text1
      expect(readerTitle(tester), equals(text1));
    });

    testWidgets(
        'prev, prev, back — Get.off() keeps a single reader on the stack '
        'so back returns to the category screen', (tester) async {
      await startApp(tester);
      await openOdesText(tester, text3);

      // prev → text2
      await tester.tap(await prevBtn(tester, text2));
      await tester.pumpAndSettle();
      expect(readerTitle(tester), equals(text2));

      // prev → text1
      await tester.tap(await prevBtn(tester, text1));
      await tester.pumpAndSettle();
      expect(readerTitle(tester), equals(text1));

      await hitCurrentBackButton(tester);

      expect(find.byType(TextReader), findsNothing);
      expect(find.byType(TextRowWidget), findsAtLeast(1));
    });
  });

  // ── next button ───────────────────────────────────────────────────────────

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

      // button is disabled — label shows "Seguinte →"
      await tester.tap(await nextBtn(tester));
      await tester.pumpAndSettle();

      // still on last text
      expect(readerTitle(tester), equals(textLast));
    });

    testWidgets(
        'next, next, back — Get.off() keeps a single reader on the stack '
        'so back returns to the category screen', (tester) async {
      await startApp(tester);
      await openOdesText(tester, text1);

      // next → text2
      await tester.tap(await nextBtn(tester, text2));

      await tester.pumpAndSettle();
      expect(readerTitle(tester), equals(text2));

      // next → text3
      await tester.tap(await nextBtn(tester, text3));
      await tester.pumpAndSettle();
      expect(readerTitle(tester), equals(text3));

      // back → category screen (not text2, because Get.off() replaced the
      // reader on the stack each time)
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

