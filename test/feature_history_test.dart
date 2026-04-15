import 'package:flutter_test/flutter_test.dart';
import 'package:pessoa_pensadora/ui/widget/s_item_widget.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('History tab is initially empty', (tester) async {
    await startApp(tester);
    await switchToHistoryTab(tester);

    expect(find.text('Nenhum texto visitado'), findsOne);
    expect(find.byType(TextListItemWidget), findsNothing);
  });

  testWidgets('Opening a text makes it appear in the History tab',
      (tester) async {
    await startApp(tester);

    await tester.tap(find.text('Odes de Ricardo Reis'));
    await tester.pumpAndSettle();

    final textFinder = find.text('A flor que és, não a que dás, eu quero. [2]');
    expect(textFinder, findsOne);
    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await switchToHistoryTab(tester);

    expect(
        find.descendant(of: find.byType(TextListItemWidget), matching: textFinder),
        findsOne);
  });

  testWidgets('Most recently read text appears first in History',
      (tester) async {
    await startApp(tester);

    await tester.tap(find.text('Odes de Ricardo Reis'));
    await tester.pumpAndSettle();

    var firstText = 'A flor que és, não a que dás, eu quero. [2]';
    final firstTextFinder = find.text(firstText);
    expect(firstTextFinder, findsOne);
    await tester.tap(firstTextFinder);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    var secondText = 'A cada qual, como a estatura, é dada';
    final secondTextFinder = find.text(secondText);
    expect(secondTextFinder, findsOne);
    await tester.tap(secondTextFinder);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await switchToHistoryTab(tester);

    final items = tester.widgetList<TextListItemWidget>(find.byType(TextListItemWidget)).toList();
    expect(items.length, greaterThanOrEqualTo(2));

    // Most recently opened should be first
    expect(items.first.title, equals(secondText));
    expect(items[1].title, equals(firstText));
  });
}
