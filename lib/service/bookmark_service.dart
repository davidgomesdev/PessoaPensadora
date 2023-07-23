import 'package:hive/hive.dart';
import 'package:pessoa_bonito/model/bookmarked_text.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';

import '../util/logger_factory.dart';

const _savedTextsBoxName = 'savedTexts';

class BookmarkService {
  final Box<BookmarkedText> _box;

  BookmarkService._(this._box);

  static Future<BookmarkService> initialize() async {
    final box = await _getSavedTextsBox();

    log.i('Saved texts box initialized successfully');

    return BookmarkService._(box);
  }

  static Future<Box<BookmarkedText>> _getSavedTextsBox() async {
    try {
      return await Hive.openBox(_savedTextsBoxName);
    } catch (ex) {
      log.w('Error opening saved texts box, re-creating it', ex);
      await Hive.deleteBoxFromDisk(_savedTextsBoxName);
      return await Hive.openBox(_savedTextsBoxName);
    }
  }

  Future<void> saveText(PessoaText text) async {
    await _box.put(text.id, BookmarkedText.from(text));
    log.i('Saved text ${text.id}');
  }

  Future<void> deleteText(int id) async {
    await _box.delete(id);
    log.i('Deleted text $id');
  }

  bool isTextSaved(int id) => _box.containsKey(id);

  List<BookmarkedText> getTexts() => _box.values.toList(growable: false);
}
