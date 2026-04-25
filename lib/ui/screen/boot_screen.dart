import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pessoa_pensadora/repository/history_store.dart';
import 'package:pessoa_pensadora/repository/read_store.dart';
import 'package:pessoa_pensadora/repository/reader_preference_store.dart';
import 'package:pessoa_pensadora/repository/saved_store.dart';
import 'package:pessoa_pensadora/service/deep_link_service.dart';
import 'package:pessoa_pensadora/service/read_controller.dart';
import 'package:pessoa_pensadora/service/saved_controller.dart';
import 'package:pessoa_pensadora/service/selection_action_service.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/screen/base_screen.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

import 'home_screen.dart';
import 'splash_screen.dart';

class BootScreen extends StatefulWidget {
  static const routeName = '/boot';

  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  DateTime startedAt = DateTime.timestamp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: initializeDependencies(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              snapshot.printError();
              return ErrorWidget(snapshot.error!);
            }

            return const SplashScreen();
          }),
    );
  }

  Future initializeDependencies(BuildContext context) async {
    final assetBundle = DefaultAssetBundle.of(context);

    final deepLinkService = DeepLinkService();
    await deepLinkService.initialize();
    Get.put(deepLinkService, permanent: true);

    Get.put(await TextStoreService.initialize(assetBundle), permanent: true);
    Get.put(SelectionActionService(), permanent: true);

    final saveRepo = await SaveRepository.initialize();
    final readRepo = await ReadRepository.initialize();

    Get.put(saveRepo, permanent: true);
    Get.put(readRepo, permanent: true);
    Get.put(await HistoryRepository.initialize(), permanent: true);
    Get.put(await ReaderPreferenceStore.initialize(), permanent: true);

    Get.put(ReadController(readRepo), permanent: true);
    Get.put(SavedController(saveRepo), permanent: true);

    final version = (await PackageInfo.fromPlatform()).version;

    log.i("Running version '$version'");

    finishedAt =
    DateTime.timestamp();
    var durationSinceStart = finishedAt!.difference(startedAt);

    log.d("Took ${durationSinceStart.inMilliseconds}ms "
        "to load dependencies.");

    final pendingPath = deepLinkService.consumePendingPath();
    if (pendingPath != null && RegExp(r'^/textReader/\d+$').hasMatch(pendingPath)) {
      Get.offAllNamed(HomeScreen.routeName);
      Get.toNamed(pendingPath);
    } else {
      Get.offAndToNamed(HomeScreen.routeName);
    }

    return Future.value();
  }
}
