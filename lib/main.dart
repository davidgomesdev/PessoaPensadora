import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pessoa_bonito/service/text_store_service.dart';
import 'package:pessoa_bonito/ui/screen/base_screen.dart';

import 'model/saved_text.dart';
import 'service/bookmark_service.dart';

Future<void> main() async {
  EquatableConfig.stringify = true;

  await Hive.initFlutter();

  Hive.registerAdapter(SavedTextAdapter());
  Hive.registerAdapter(SavedCategoryAdapter());

  runApp(const BootScreen());
}

class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializeDependencies(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            snapshot.printError();
            return ErrorWidget(snapshot.error!);
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return const App();
          }

          return const CircularProgressIndicator();
        });
  }

  Future initializeDependencies(BuildContext context) async {
    Get.put(await BookmarkService.initialize());

    final assetBundle = DefaultAssetBundle.of(context);
    Get.put(await TextStoreService.initialize(assetBundle));

    return Future.value();
  }
}
