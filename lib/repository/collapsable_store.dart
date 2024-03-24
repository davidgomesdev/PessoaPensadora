import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pessoa_bonito/service/text_store.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

const _savedCollapsableBoxName = 'collapsable';

class CollapsableRepository {
  final Box<bool> _box;
  final Rx<bool> isAllCollapsed;

  CollapsableRepository._(this._box, this.isAllCollapsed);

  static Future<CollapsableRepository> initialize() async {
    final box = await _getCollapsableBox();

    log.i('Collapsable box initialized successfully');

    return CollapsableRepository._(
        box, box.values.every((isCollapsed) => isCollapsed == true).obs);
  }

  static Future<Box<bool>> _getCollapsableBox() async {
    return await Hive.openBox(_savedCollapsableBoxName);
  }

  Future<void> setStatus(int categoryId, bool isCollapsed) async {
    await _box.put(categoryId, isCollapsed);

    final newStatus = areAllCollapsed();
    isAllCollapsed.value = newStatus;

    log.i('Set expanded status of category id $categoryId to $isCollapsed');
  }

  Future<void> addCategory(int categoryId) async {
    final status = areAllCollapsed();

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

  bool areAllCollapsed() => _box.values.every((isCollapsed) => isCollapsed);

  Future<void> toggleAllStatus() async {
    final newStatus = !areAllCollapsed();

    isAllCollapsed.value = newStatus;

    for (var categoryId in _box.keys) {
      await _box.put(categoryId, newStatus);
    }

    log.i('Set collapsable status of all texts to $newStatus');
  }
}
