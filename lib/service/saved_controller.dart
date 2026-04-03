import 'package:get/get.dart';
import 'package:pessoa_pensadora/model/saved_text.dart';
import 'package:pessoa_pensadora/repository/saved_store.dart';
import 'package:pessoa_pensadora/util/action_feedback.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

import 'read_controller.dart';

class SavedController extends GetxController {
  final SaveRepository _repo;

  SavedController(this._repo);

  final savedIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    savedIds.addAll(_repo.getTexts().map((t) => t.id));
  }

  Future<void> toggle(int id) async {
    if (savedIds.contains(id)) {
      await _repo.deleteText(id);
      savedIds.remove(id);
      log.i('Removed text $id from saved');
    } else {
      await _repo.saveText(SavedText(id));
      savedIds.add(id);
      // Also mark as read when saving
      try {
        final readCtrl = Get.find<ReadController>();
        await readCtrl.markRead(id);
      } catch (_) {}
      ActionFeedback.lightHaptic();
      log.i('Saved text $id');
    }
  }

  bool isSaved(int id) => savedIds.contains(id);
}
