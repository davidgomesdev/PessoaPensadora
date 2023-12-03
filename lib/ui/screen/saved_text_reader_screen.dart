import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/ui/widget/text_reader.dart';

class TextReaderScreen extends StatelessWidget {
  const TextReaderScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: TextReader(
            categoryTitle: Get.arguments['categoryTitle'],
            title: Get.arguments['title'],
            content: Get.arguments['content'],
            author: Get.arguments['author'],
          ),
        ),
      ),
    );
  }
}
