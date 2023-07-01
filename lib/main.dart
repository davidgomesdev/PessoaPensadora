import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pessoa_bonito/ui/screen/base_screen.dart';
import 'package:pessoa_bonito/ui/service/boot_service.dart';

import 'model/pessoa_text.dart';

Future<void> main() async {
  EquatableConfig.stringify = true;

  await Hive.initFlutter();

  Hive.registerAdapter(PessoaTextAdapter());

  runApp(const BootScreen());
}

class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BootService bootService = BootService();

    return FutureBuilder(
        future: bootService.initializeDependencies(context),
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
}
