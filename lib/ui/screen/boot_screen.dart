import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/repository/collapsable_store.dart';
import 'package:pessoa_bonito/repository/history_store.dart';
import 'package:pessoa_bonito/repository/read_store.dart';
import 'package:pessoa_bonito/repository/saved_store.dart';
import 'package:pessoa_bonito/service/text_store.dart';
import 'package:pessoa_bonito/ui/routes.dart';

import 'splash_screen.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
    Get.put(await TextStoreService.initialize(assetBundle), permanent: true);

    Get.put(await SaveRepository.initialize(), permanent: true);
    Get.put(await ReadRepository.initialize(), permanent: true);
    Get.put(await HistoryRepository.initialize(), permanent: true);
    Get.put(await CollapsableRepository.initialize(), permanent: true);

    Get.offAndToNamed(Routes.homeScreen);

    return Future.value();
  }
}
