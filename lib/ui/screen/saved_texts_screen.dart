import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/model/saved_text.dart';
import 'package:pessoa_bonito/service/bookmark_service.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';

import '../routes.dart';

class SavedTextsScreen extends StatelessWidget {
  const SavedTextsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookmarkService service = Get.find();
    final texts = service.getTexts();

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
            sliver: SliverList.list(
                children: [...texts.map((text) => SavedTextTile(text))]),
          )
        ],
      ),
    );
  }
}

class SavedTextTile extends StatelessWidget {
  final SavedText text;

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
          "text": text.toModel()
        });
      },
    );
  }
}
