import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mockito/mockito.dart';
import 'package:pessoa_pensadora/dto/box/box_person_category.dart';
import 'package:pessoa_pensadora/dto/box/box_person_text.dart';
import 'package:pessoa_pensadora/model/saved_text.dart';
import 'package:pessoa_pensadora/repository/collapsable_store.dart';
import 'package:pessoa_pensadora/repository/history_store.dart';
import 'package:pessoa_pensadora/repository/read_store.dart';
import 'package:pessoa_pensadora/repository/reader_preference_store.dart';
import 'package:pessoa_pensadora/repository/saved_store.dart';
import 'package:pessoa_pensadora/service/selection_action_service.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/routes.dart';
import 'package:pessoa_pensadora/ui/screen/base_screen.dart';

import 'boot_service_test.mocks.dart';

Future<void> startApp(WidgetTester tester) async {
  await initializeDependencies(tester);

  await tester.runAsync(() async {
    await tester.pumpWidget(App(
      initialLocale: Locale('pt'),
    ));
    await tester.pumpAndSettle();
  });

  Get.offAndToNamed(Routes.homeScreen);

  await tester.pumpAndSettle();
}

Future<void> openDrawer(WidgetTester tester) async {
  final ScaffoldState state = tester.firstState(find.byType(Scaffold));

  state.openDrawer();

  await tester.pumpAndSettle();
}

Future<TextStoreService> initializeDependencies(WidgetTester tester) async {
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
      // ignored: The Hive dependency has a deadlock issue in this method, the 5th test run was hanging here
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

    Get.put(await SaveRepository.initialize(), permanent: true);
    Get.put(await ReadRepository.initialize(), permanent: true);
    Get.put(await HistoryRepository.initialize(), permanent: true);
    Get.put(await CollapsableRepository.initialize(), permanent: true);
    Get.put(await ReaderPreferenceStore.initialize(), permanent: true);
    Get.put(SelectionActionService(), permanent: true);
  });

  return Get.find<TextStoreService>();
}

Future<void> dragDrawerUntilVisible(WidgetTester tester, Finder finder,
    {int maxIterations = 50}) async {
  await tester.dragUntilVisible(
      finder,
      find.byKey(const PageStorageKey("drawer-list-view")),
      const Offset(0, -200),
      maxIteration: maxIterations);
}

Future<void> switchReadingTypeToMain(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.unfold_less_double_rounded));
  await tester.pumpAndSettle();
}

Future<void> switchReadingTypeToFull(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.read_more_rounded));
  await tester.pumpAndSettle();
}

Future<void> enterBookmarkScreen(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.bookmark_outline_outlined));
  await tester.pumpAndSettle();
}

Future<void> hitBackDrawerButton(WidgetTester tester) async {
  await tester.tap(find.text('back'.tr));
  await tester.pumpAndSettle();
}
