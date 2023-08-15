import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/model/saved_text.dart';
import 'package:pessoa_bonito/service/save_service.dart';

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
    final SaveService service = Get.find();

    return IconButton(
        onPressed: () {
          setState(() {
            if (service.isTextSaved(textId)) {
              service.deleteText(textId);
            } else {
              service.saveText(widget.text);
            }
          });
        },
        icon: Icon(service.isTextSaved(textId)
            ? Icons.bookmark_outlined
            : Icons.bookmark_outline_outlined));
  }
}
