import 'package:hive/hive.dart';

import '../util/logger_factory.dart';

const _savedTextsBoxName = 'readTexts';

class ReadRepository {
  final Box<bool> _box;

  ReadRepository._(this._box);

  static Future<ReadRepository> initialize() async {
    final box = await _getReadTextsBox();

    log.d('Read texts box initialized successfully');
    log.d('Texts found in box: ${box.keys}');

    return ReadRepository._(box);
  }

  static Future<Box<bool>> _getReadTextsBox() async {
    return await Hive.openBox(_savedTextsBoxName);
  }

  Future<void> toggleRead(int id) async {
    final readState = _box.get(id) ?? false;

    await _box.put(id, !readState);

    log.i("Set text id '$id' read status to ${!readState}");
  }

  Future<void> markAsRead(int id) async {
    await _box.put(id, true);

    log.i('Marked text id $id as read');
  }

  bool isTextRead(int id) => _box.get(id) == true;
}
