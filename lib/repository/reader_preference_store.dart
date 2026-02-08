import 'dart:ui';

import 'package:flag/flag_enum.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

const _readerPreferenceBoxName = 'reader_preference';

enum Language {
  portuguese('pt', Locale('pt'), FlagsCode.PT),
  english('en', Locale('en'), FlagsCode.GB);

  final String code;
  final Locale locale;
  final FlagsCode flagCode;

  const Language(this.code, this.locale, this.flagCode);

  static Language fromCode(String code) {
    return Language.values.firstWhere((lang) => lang.code == code,
        orElse: () => Language.portuguese);
  }

  Language next() {
    final nextIndex =
        (Language.values.indexOf(this) + 1) % Language.values.length;
    return Language.values[nextIndex];
  }
}

class ReaderPreferenceStore {
  final Box<String> _box;

  ReaderPreferenceStore(this._box);

  static Future<ReaderPreferenceStore> initialize() async {
    final Box<String> box = await Hive.openBox(_readerPreferenceBoxName);
    final instance = ReaderPreferenceStore(box);

    log.d('Reader preference box initialized successfully');

    return instance;
  }

  Future<void> changeLanguage() async {
    final nextLocale = currentLanguage.next();

    await _box.put('language', nextLocale.code);
    await Get.updateLocale(nextLocale.locale);

    log.i("Set language to '$nextLocale'");
  }

  Future<void> swapReadingMode() async {
    final newModeValue = isFullReadingMode ? 'main' : 'full';

    await _box.put('isReadingMode', newModeValue);

    log.i("Set reading mode to '$newModeValue'");
  }

  Language get currentLanguage {
    return Language.fromCode(_box.get('language', defaultValue: 'pt')!);
  }

  bool get isFullReadingMode {
    final modeValue = _box.get('isReadingMode', defaultValue: 'main');
    return modeValue == 'full';
  }
}
