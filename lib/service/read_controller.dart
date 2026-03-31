import 'package:get/get.dart';
import 'package:pessoa_pensadora/repository/read_store.dart';

class ReadController extends GetxController {
  final ReadRepository _repo;

  ReadController(this._repo);

  final readIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    readIds.addAll(_repo.getAllReadIds());
  }

  Future<void> toggle(int id) async {
    await _repo.toggleRead(id);
    if (readIds.contains(id)) {
      readIds.remove(id);
    } else {
      readIds.add(id);
    }
  }

  Future<void> markRead(int id) async {
    await _repo.markAsRead(id);
    readIds.add(id);
  }

  bool isRead(int id) => readIds.contains(id);
}

