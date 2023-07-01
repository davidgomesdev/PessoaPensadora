import 'package:hive/hive.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/model/saved_text.dart';

import '../util/logger_factory.dart';

class ActionService {
  final Box<SavedText> _box;

  ActionService(this._box);

  Future<void> saveText(PessoaText text) async {
    await _box.put(text.id, SavedText.from(text));
    log.i('Saved text ${text.id}');
  }

  Future<void> deleteText(int id) async {
    await _box.delete(id);
    log.i('Deleted text $id');
  }

  bool isTextSaved(int id) => _box.containsKey(id);

  List<SavedText> getTexts() => _box.values.toList(growable: false);
}
