import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/ui/widget/share_text_button.dart';
import 'package:pessoa_bonito/ui/widget/text_reader.dart';

class TextReaderScreen extends StatelessWidget {
  const TextReaderScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String text = Get.arguments['content'];
    final String author = Get.arguments['author'];

    return Scaffold(
      appBar: AppBar(
        actions: [
          ShareTextButton(
              text: text, author: author)
        ],
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: TextReader(
            categoryTitle: Get.arguments['categoryTitle'],
            title: Get.arguments['title'],
            content: text,
            author: author,
          ),
        ),
      ),
    );
  }
}
