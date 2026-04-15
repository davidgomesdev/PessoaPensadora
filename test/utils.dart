import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:mockito/mockito.dart';
import 'package:pessoa_pensadora/dto/box/box_person_category.dart';
import 'package:pessoa_pensadora/dto/box/box_person_text.dart';
import 'package:pessoa_pensadora/model/saved_text.dart';
import 'package:pessoa_pensadora/repository/collapsable_store.dart';
import 'package:pessoa_pensadora/repository/history_store.dart';
import 'package:pessoa_pensadora/repository/read_store.dart';
import 'package:pessoa_pensadora/repository/reader_preference_store.dart';
import 'package:pessoa_pensadora/repository/saved_store.dart';
import 'package:pessoa_pensadora/service/read_controller.dart';
import 'package:pessoa_pensadora/service/saved_controller.dart';
import 'package:pessoa_pensadora/service/selection_action_service.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/screen/base_screen.dart';
import 'package:pessoa_pensadora/ui/screen/home_screen.dart';
import 'package:pessoa_pensadora/ui/widget/text_row_widget.dart';

import 'boot_service_test.mocks.dart';

Future<void> startApp(WidgetTester tester) async {
  await initializeDependencies(tester);

  await tester.runAsync(() async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
  });

  Get.offAndToNamed(HomeScreen.routeName);

  await tester.pumpAndSettle();
}

Future<TextStoreService> initializeDependencies(WidgetTester tester) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  finishedAt = DateTime.timestamp();
  final randomPath = "./temp-tests/${DateTime.timestamp()}";
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/path_provider');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    return randomPath;
  });

  await tester.runAsync(() async {
    Get.reset();
    Hive.resetAdapters();

    try {
      await Hive.close().timeout(const Duration(seconds: 1));
    } on TimeoutException catch (_) {
      // ignored: The Hive dependency has a deadlock issue in this method
    }

    await Hive.initFlutter(".");

    EquatableConfig.stringify = true;

    Hive.registerAdapter(BoxPessoaCategoryAdapter());
    Hive.registerAdapter(BoxPessoaTextAdapter());
    Hive.registerAdapter(SavedTextAdapter());

    final realJson =
        await File('assets/json_files/all_texts.json').readAsString();

    final assetBundleMock = MockAssetBundle();

    when(assetBundleMock.loadString(any)).thenAnswer((_) async => realJson);

    final service = await TextStoreService.initialize(assetBundleMock);

    Get.put(service);

    var savedRepository = await SaveRepository.initialize();
    var readRepository = await ReadRepository.initialize();

    Get.put(savedRepository, permanent: true);
    Get.put(readRepository, permanent: true);
    Get.put(await HistoryRepository.initialize(), permanent: true);
    Get.put(await CollapsableRepository.initialize(), permanent: true);
    Get.put(await ReaderPreferenceStore.initialize(), permanent: true);
    Get.put(SavedController(savedRepository), permanent: true);
    Get.put(ReadController(readRepository), permanent: true);
    Get.put(SelectionActionService(), permanent: true);
  });

  return Get.find<TextStoreService>();
}

Future<void> switchToSavedTab(WidgetTester tester) async {
  await tester.tap(find.text('GUARDADOS'));
  await tester.pumpAndSettle();
}

Future<void> switchToHistoryTab(WidgetTester tester) async {
  await tester.tap(find.text('HISTÓRICO'));
  await tester.pumpAndSettle();
}

Future<void> switchToBrowseTab(WidgetTester tester) async {
  await tester.tap(find.text('EXPLORAR'));
  await tester.pumpAndSettle();
}

Future<void> saveCurrentText(WidgetTester tester) async {
  var saveButton = find.text('♡  Guardar');
  expect(saveButton, findsOne);
  await tester.tap(saveButton);

  await expectEventuallyWithPump(tester, () {
    expect(find.text('♥  Guardado'), findsOne);
  });
}

Future<void> submitText(WidgetTester tester) async {
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

Future<void> scrollUntilVisibleInBrowse(
  WidgetTester tester,
  Finder finder, {
  double scrollDelta = 200,
}) async {
  final scrollable = find.descendant(
    of: find.byType(BrowseTab),
    matching: find.byType(Scrollable),
  );
  expect(scrollable, findsOne);
  await tester.scrollUntilVisible(
    finder,
    scrollDelta,
    scrollable: scrollable.first
  );
  await tester.pumpAndSettle();
}

Future<void> scrollUntilVisibleInCategory(
  WidgetTester tester,
  Finder finder, {
  double scrollDelta = 50,
}) async {
  final scrollable = find.descendant(
    of: find.byType(ListView),
    matching: find.byType(Scrollable),
  );
  expect(scrollable, findsOne);
  await tester.scrollUntilVisible(
    finder,
    scrollDelta,
    scrollable: scrollable.first,
    maxScrolls: 1000
  );
  await tester.pumpAndSettle();
}

/// Pump and retry expect statements until they pass or timeout.
/// This helps avoid false negatives due to async delays in Hive operations.
Future<void> expectEventuallyWithPump(
    WidgetTester tester,
    void Function() testFn, {
      Duration timeout = const Duration(seconds: 5),
      Duration pumpInterval = const Duration(milliseconds: 100),
    }) async {
  final stopwatch = Stopwatch()..start();
  TestFailure? lastFailure;

  while (stopwatch.elapsed < timeout) {
    try {
      testFn();
      return;
    } on TestFailure catch (e) {
      lastFailure = e;
      await tester.pump(pumpInterval);
    }
  }

  if (lastFailure != null) {
    throw lastFailure;
  }
}

List<String?> getCategoryScreenTexts() {
  return find
      .descendant(
          of: find.byType(TextRowWidget, skipOffstage: false),
          matching: find.byWidgetPredicate(
              (w) => w is Text && (w.data?.isNotEmpty ?? false),
              skipOffstage: false),
          skipOffstage: false)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .toList();
}
