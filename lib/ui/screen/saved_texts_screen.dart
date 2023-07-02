import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/model/saved_text.dart';
import 'package:pessoa_bonito/service/action_service.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';

import '../routes.dart';

class SavedTextsScreen extends StatelessWidget {
  const SavedTextsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ActionService service = Get.find();
    final texts = service.getTexts();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("Saved texts", style: bonitoTextTheme.displaySmall),
            pinned: true),
          SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              sliver: SliverList.list(
                  children: [...texts.map((text) => SavedTextTile(text))]))
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
    return ListTile(
      title: Text(text.title, style: bonitoTextTheme.displaySmall),
      minVerticalPadding: 8.0,
      subtitle: Text(
          text.content.replaceAll("\n\n", "\n").trim(),
          overflow: TextOverflow.ellipsis, maxLines: 2),
      trailing: Text(text.author),
      onTap: () {
        Get.toNamed(Routes.readSavedScreen, arguments: {
          "categoryTitle": text.category.title,
          "text": text.toModel()
        });
      },
    );
  }
}
