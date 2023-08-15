import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/dto/box/box_person_text.dart';
import 'package:pessoa_bonito/service/save_service.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';

import '../routes.dart';

class SavedTextsScreen extends StatelessWidget {
  const SavedTextsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SaveService service = Get.find();
    final bookmarkedTexts = service.getTexts();

    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
        slivers: [
          SliverAppBar(
            title: Text("Saved texts", style: bonitoTextTheme.displaySmall),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            sliver: SliverList.list(children: [
              ...bookmarkedTexts.map(
                  (bookmarkedText) => SavedTextTile(bookmarkedText.toModel()))
            ]),
          )
        ],
      ),
    );
  }
}

class SavedTextTile extends StatelessWidget {
  final BoxPessoaText text;

  const SavedTextTile(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var textCondensed = text.content.replaceAll("\n\n", "\n").trim();

    return ListTile(
      enableFeedback: true,
      title: Text(
        text.title,
        style:
            bonitoTextTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textCondensed,
              style: bonitoTextTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  text.author,
                  textAlign: TextAlign.right,
                  style: bonitoTextTheme.labelSmall,
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Get.toNamed(Routes.readSavedScreen, arguments: {
          "categoryTitle": text.category.title,
          "title": text.title,
          "content": text.content,
          "author": text.author,
        });
      },
    );
  }
}
