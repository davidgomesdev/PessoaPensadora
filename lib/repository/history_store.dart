import 'package:hive/hive.dart';

import '../util/logger_factory.dart';

const _historyBoxName = 'history';

class HistoryRepository {
  final Box<int> _box;
  
  HistoryRepository._(this._box);

  static Future<HistoryRepository> initialize() async {
    final box = await _getHistoryBox();

    log.i('History box initialized successfully');
    log.d('Text ids found in history box: ${box.values}');

    return HistoryRepository._(box);
  }

  static Future<Box<int>> _getHistoryBox() async {
    return await Hive.openBox(_historyBoxName);
  }

  Future<void> saveVisit(int id) async {
    await _box.add(id);

    log.i("Appended text '$id' to history");
  }

  Future<Iterable<int>> getHistory() async {
    final ids = List<int>.empty(growable: true);

    _box.values.toList().reversed.forEach((id) {
      if (!ids.contains(id)) ids.add(id);
    });

    return ids;
  }
}
