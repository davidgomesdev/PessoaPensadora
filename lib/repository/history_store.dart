import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../util/logger_factory.dart';

const _historyBoxName = 'history';

class HistoryRepository {
  final Box<int> _box;

  final historyIds = <int>[].obs;

  HistoryRepository._(this._box) {
    historyIds.assignAll(_box.values.toList().reversed);
  }

  static Future<HistoryRepository> initialize() async {
    final box = await _getHistoryBox();

    log.d('History box initialized successfully');
    log.i('Text ids found in history box: ${box.values}');

    return HistoryRepository._(box);
  }

  static Future<Box<int>> _getHistoryBox() async {
    return await Hive.openBox(_historyBoxName);
  }

  Future<void> saveVisit(int id) async {
    var current = _box.values.toList();

    // prevent duplicate
    current.remove(id);

    historyIds.assignAll([id, ...current.reversed]);

    await _box.add(id);

    log.i("Appended text '$id' to history");
  }

  Future<Iterable<int>> getHistory() async => _box.values.toList().reversed;
}
