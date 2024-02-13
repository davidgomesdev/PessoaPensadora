import 'package:hive/hive.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

const _savedCollapsableBoxName = 'collapsable';

class CollapsableRepository {
  final Box<bool> _box;

  CollapsableRepository._(this._box);

  static Future<CollapsableRepository> initialize() async {
    final box = await _getCollapsableBox();

    log.i('Collapsable box initialized successfully');

    return CollapsableRepository._(box);
  }

  static Future<Box<bool>> _getCollapsableBox() async {
    return await Hive.openBox(_savedCollapsableBoxName);
  }

  Future<void> setStatus(int categoryId, bool isExpanded) async {
    await _box.put(categoryId, isExpanded);

    log.i('Set expanded status of category id $categoryId to $isExpanded');
  }

  bool isExpanded(int categoryId) => _box.get(categoryId) == true;
}
