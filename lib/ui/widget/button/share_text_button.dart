import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/service/selection_action_service.dart';

class ShareTextButton extends StatelessWidget {
  final int textId;
  final String text, author;

  const ShareTextButton({super.key, required this.textId, required this.text, required this.author});

  @override
  Widget build(BuildContext context) {
    final SelectionActionService service = Get.find();

    return PopupMenuButton<_ShareOption>(
      icon: const Icon(Icons.ios_share_rounded),
      tooltip: "Partilhar",
      onSelected: (option) {
        if (option == _ShareOption.url) {
          service.shareUrl(textId);
        } else {
          service.shareText(text, author);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _ShareOption.url,
          child: ListTile(
            leading: Icon(Icons.link),
            title: Text('Partilhar ligação'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _ShareOption.text,
          child: ListTile(
            leading: Icon(Icons.article_outlined),
            title: Text('Partilhar texto'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

enum _ShareOption { url, text }
