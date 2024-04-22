import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mockito/mockito.dart';
import 'package:pessoa_bonito/dto/box/box_person_category.dart';
import 'package:pessoa_bonito/dto/box/box_person_text.dart';
import 'package:pessoa_bonito/model/saved_text.dart';
import 'package:pessoa_bonito/repository/collapsable_store.dart';
import 'package:pessoa_bonito/repository/history_store.dart';
import 'package:pessoa_bonito/repository/read_store.dart';
import 'package:pessoa_bonito/repository/saved_store.dart';
import 'package:pessoa_bonito/service/selection_action_service.dart';
import 'package:pessoa_bonito/service/text_store.dart';
import 'package:pessoa_bonito/ui/routes.dart';
import 'package:pessoa_bonito/ui/screen/base_screen.dart';

import 'boot_service_test.mocks.dart';

Future<void> startApp(WidgetTester tester) async {
  await initializeDependencies(tester);

  await tester.runAsync(() async {
    await tester.pumpWidget(const App());
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

    final realJson = await File('assets/json_files/texts.json').readAsString();

    final assetBundleMock = MockAssetBundle();

    when(assetBundleMock.loadString(any)).thenAnswer((_) async => realJson);

    final service = await TextStoreService.initialize(assetBundleMock);

    Get.put(service);

    Get.put(await SaveRepository.initialize(), permanent: true);
    Get.put(await ReadRepository.initialize(), permanent: true);
    Get.put(await HistoryRepository.initialize(), permanent: true);
    Get.put(await CollapsableRepository.initialize(), permanent: true);
    Get.put(SelectionActionService(), permanent: true);
  });

  return Get.find<TextStoreService>();
}

Finder findScrollableTile(Finder tileFinder) {
  return find.descendant(
      of: tileFinder,
      matching: find.byWidgetPredicate((w) => w is Scrollable),
      matchRoot: true);
}
