import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:pessoa_pensadora/dto/box/box_person_text.dart';
import 'package:pessoa_pensadora/ui/screen/base_screen.dart';

import 'dto/box/box_person_category.dart';
import 'model/saved_text.dart';

Future<void> main() async {
  EquatableConfig.stringify = true;

  if (kIsWeb) usePathUrlStrategy();

  await Hive.initFlutter();

  Hive.registerAdapter(BoxPessoaCategoryAdapter());
  Hive.registerAdapter(BoxPessoaTextAdapter());
  Hive.registerAdapter(SavedTextAdapter());

  runApp(const App());
}
