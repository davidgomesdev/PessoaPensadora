import 'package:hive/hive.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

const _readerPreferenceBoxName = 'reader_preference';

class ReaderPreferenceStore {
  final Box<String> _box;

  ReaderPreferenceStore(this._box);

  static Future<ReaderPreferenceStore> initialize() async {
    final Box<String> box = await Hive.openBox(_readerPreferenceBoxName);
    final instance = ReaderPreferenceStore(box);

    log.d('Reader preference box initialized successfully');

    return instance;
  }

  Future<void> swapReadingMode() async {
    final newModeValue = isFullReadingMode ? 'main' : 'full';

    await _box.put('isReadingMode', newModeValue);

    log.i("Set reading mode to '$newModeValue'");
  }

  bool get isFullReadingMode {
    final modeValue = _box.get('isReadingMode', defaultValue: 'main');
    return modeValue == 'full';
  }
}