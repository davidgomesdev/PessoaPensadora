import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:pessoa_pensadora/model/saved_text.dart';
import 'package:pessoa_pensadora/repository/collapsable_store.dart';
import 'package:pessoa_pensadora/service/text_store.dart';

import '../util/logger_factory.dart';

const _savedTextsBoxName = 'savedTexts';

class SaveRepository {
  final Box<SavedText> _box;

  final TextStoreService service = Get.find();

  SaveRepository._(this._box);

  static Future<SaveRepository> initialize() async {
    final box = await _getSavedTextsBox();

    log.d('Saved texts box initialized successfully');
    log.i('Texts found in box: ${box.keys}');

    return SaveRepository._(box);
  }

  static Future<Box<SavedText>> _getSavedTextsBox() async {
    return await Hive.openBox(_savedTextsBoxName);
  }

  Future<void> saveText(SavedText text) async {
    await _box.put(text.id, text).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        log.w('Hive.put() timed out! Proceeding anyway.');
      },
    ).catchError((e) {
      log.e('Error during Hive.put(). Proceeding anyway.', error: e);
    });

    final rootCategoryId = service.getTextRootCategory(text.id).id;
    final isFirstOfRootCategory = _box.values
        .map((text) => service.getTextRootCategory(text.id).id)
        .none((current) => current == rootCategoryId);

    if (isFirstOfRootCategory) {
      final CollapsableRepository collapsableStore = Get.find();

      try {
        await collapsableStore.addCategory(rootCategoryId);
      } catch (e) {
        log.w('Error adding category: $e');
      }
    }

    log.i('Saved text ${text.id}');
  }

  Future<void> deleteText(int id) async {
    await _box.delete(id).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        log.w('Hive.put() timed out! Proceeding anyway.');
      },
    ).catchError((e) {
      log.e('Error during Hive.put(): $e. Proceeding anyway.', error: e);
    });

    final rootCategoryId = service.getTextRootCategory(id).id;
    final isLastOfRootCategory = _box.values
        .map((text) => service.getTextRootCategory(text.id).id)
        .none((current) => current == rootCategoryId);

    if (isLastOfRootCategory) {
      final CollapsableRepository collapsableStore = Get.find();

      await collapsableStore.removeCategory(rootCategoryId);
    }

    log.i('Deleted saved text $id');
  }

  bool isTextSaved(int id) => _box.containsKey(id);

  List<SavedText> getTexts() => _box.values.toList(growable: false);
}
