import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pessoa_bonito/repository/saved_store.dart';
import 'package:pessoa_bonito/service/text_store.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

const _savedCollapsableBoxName = 'collapsable';

class CollapsableRepository {
  final Box<bool> _box;
  final Rx<bool> isAllCollapsed;

  final TextStoreService service = Get.find();
  final SaveRepository saveRepository = Get.find();

  CollapsableRepository._(this._box, this.isAllCollapsed);

  static Future<CollapsableRepository> initialize() async {
    final box = await _getCollapsableBox();

    log.i('Collapsable box initialized successfully');

    final instance = CollapsableRepository._(
        box,
        (box.values.every((isCollapsed) => isCollapsed == true) &&
                box.values.isNotEmpty)
            .obs);

    await instance._cleanupLeftovers();

    return instance;
  }

  // Cleans up categories that don't have texts saved
  Future<void> _cleanupLeftovers() async {
    final categories = _box.keys.map((id) => service.getCategory(id));
    final savedTexts = saveRepository.getTexts();

    log.i('Root categories in the box: ${categories.map((c) => c.title)}');

    final leftoverCategories = categories.where((cat) => savedTexts
        .none((text) => service.getTextRootCategory(text.id).id == cat.id));

    await _box.deleteAll(leftoverCategories.map((c) => c.id));

    log.i('Cleaned leftovers: ${leftoverCategories.map((c) => c.title)}');
  }

  static Future<Box<bool>> _getCollapsableBox() async {
    return await Hive.openBox(_savedCollapsableBoxName);
  }

  Future<void> setStatus(int categoryId, bool isCollapsed) async {
    await _box.put(categoryId, isCollapsed);

    final newStatus = _areAllCollapsed();
    isAllCollapsed.value = newStatus;

    log.i('Set expanded status of category id $categoryId to $isCollapsed');
  }

  Future<void> addCategory(int categoryId) async {
    final status = _areAllCollapsed();

    await _box.put(categoryId, status);

    log.i('Added category $categoryId to collapsable store (status $status)');
  }

  Future<void> removeCategory(int categoryId) async {
    await _box.delete(categoryId);
    log.i('Removed category $categoryId from collapsable store');
  }

  bool isCollapsed(int categoryId) {
    bool? isCollapsed = _box.get(categoryId);

    if (isCollapsed == null) {
      _box.put(categoryId, isCollapsed = isAllCollapsed.value);
    }

    return isCollapsed;
  }

  bool _areAllCollapsed() =>
      _box.values.every((isCollapsed) => isCollapsed) && _box.values.isNotEmpty;

  Future<void> toggleAllStatus() async {
    final newStatus = !_areAllCollapsed();

    isAllCollapsed.value = newStatus;

    for (var categoryId in _box.keys) {
      await _box.put(categoryId, newStatus);
    }

    log.i('Set collapsable status of all texts to $newStatus');
  }
}
