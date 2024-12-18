import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/ui/widget/button/share_text_button.dart';
import 'package:pessoa_pensadora/ui/widget/reader/text_reader.dart';

import '../widget/button/arquivo_pessoa_button.dart';

class TextReaderScreen extends StatelessWidget {
  const TextReaderScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final int id = Get.arguments['id'];
    final String text = Get.arguments['content'];
    final String author = Get.arguments['author'];

    return Scaffold(
      appBar: AppBar(
        actions: [
          ArquivoPessoaButton(textId: id),
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
