import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pessoa_pensadora/dto/box/box_person_text.dart';
import 'package:pessoa_pensadora/repository/reader_preference_store.dart';
import 'package:pessoa_pensadora/ui/screen/base_screen.dart';

import 'dto/box/box_person_category.dart';
import 'model/saved_text.dart';

Future<void> main() async {
  EquatableConfig.stringify = true;

  await Hive.initFlutter();
  var readerPreferenceStore = await ReaderPreferenceStore.initialize();

  Get.put(readerPreferenceStore, permanent: true);

  Hive.registerAdapter(BoxPessoaCategoryAdapter());
  Hive.registerAdapter(BoxPessoaTextAdapter());
  Hive.registerAdapter(SavedTextAdapter());

  runApp(App(initialLocale: readerPreferenceStore.currentLanguage.locale));
}
