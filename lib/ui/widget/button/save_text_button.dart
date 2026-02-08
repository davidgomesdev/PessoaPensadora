import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/model/saved_text.dart';
import 'package:pessoa_pensadora/repository/saved_store.dart';
import 'package:pessoa_pensadora/util/action_feedback.dart';

import '../../../repository/read_store.dart';

class SaveTextButton extends StatefulWidget {
  final SavedText text;

  const SaveTextButton({super.key, required this.text});

  @override
  State<SaveTextButton> createState() => _SaveTextButtonState();
}

class _SaveTextButtonState extends State<SaveTextButton> {
  int get textId => widget.text.id;

  @override
  Widget build(BuildContext context) {
    final SaveRepository repository = Get.find();
    final ReadRepository readRepository = Get.find();

    return IconButton(
      onPressed: () {
        setState(() {
          if (repository.isTextSaved(textId)) {
            repository.deleteText(textId);
          } else {
            readRepository.markAsRead(textId);
            repository.saveText(widget.text);
            ActionFeedback.lightHaptic();
          }
        });
      },
      icon: Icon(repository.isTextSaved(textId)
          ? Icons.bookmark_outlined
          : Icons.bookmark_outline_outlined),
      tooltip: 'bookmark'.tr,
    );
  }
}
