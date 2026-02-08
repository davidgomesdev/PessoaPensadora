import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/service/selection_action_service.dart';

class ShareTextButton extends StatelessWidget {
  final String text, author;

  const ShareTextButton({super.key, required this.text, required this.author});

  @override
  Widget build(BuildContext context) {
    final SelectionActionService service = Get.find();

    return IconButton(
      onPressed: () {
        service.shareText(text, author);
      },
      icon: const Icon(Icons.ios_share_rounded),
      tooltip: 'share'.tr,
    );
  }
}
