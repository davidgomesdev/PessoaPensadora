import 'package:hive/hive.dart';
import 'package:pessoa_bonito/model/saved_text.dart';

import '../util/logger_factory.dart';

const _savedTextsBoxName = 'savedTexts';

class SaveService {
  final Box<SavedText> _box;

  SaveService._(this._box);

  static Future<SaveService> initialize() async {
    final box = await _getSavedTextsBox();

    log.i('Saved texts box initialized successfully');
    log.d('Texts found in box: ${box.keys}');

    return SaveService._(box);
  }

  static Future<Box<SavedText>> _getSavedTextsBox() async {
    try {
      return await Hive.openBox(_savedTextsBoxName);
    } catch (ex) {
      log.w('Error opening saved texts box, re-creating it', ex);
      await Hive.deleteBoxFromDisk(_savedTextsBoxName);
      return await Hive.openBox(_savedTextsBoxName);
    }
  }

  Future<void> saveText(SavedText text) async {
    await _box.put(text.id, text);
    log.i('Saved text ${text.id}');
  }

  Future<void> deleteText(int id) async {
    await _box.delete(id);
    log.i('Deleted text $id');
  }

  bool isTextSaved(int id) => _box.containsKey(id);

  List<SavedText> getTexts() => _box.values.toList(growable: false);
}
