import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/service/saved_controller.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/routes.dart';
import 'package:pessoa_pensadora/ui/widget/group_header_widget.dart';
import 'package:pessoa_pensadora/ui/widget/s_item_widget.dart';

class SavedTextsScreen extends StatelessWidget {
  const SavedTextsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedCtrl = Get.find<SavedController>();
    final store = Get.find<TextStoreService>();

    return Scaffold(
      backgroundColor: BonitoTheme.bgPrimary,
      body: CustomScrollView(
        slivers: [
          Obx(() {
            final savedIdSet = savedCtrl.savedIds.toSet();
            if (savedIdSet.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    // todo: explain how to save texts and add something like "Pessoa tem tantos textos incríveis, não percas os teus favoritos!"
                    'Nenhum texto guardado :(',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: BonitoTheme.textMuted),
                  ),
                ),
              );
            }

            final items = <Widget>[];

            for (final cat in store.mainIndex.subcategories) {
              final savedInGroup = savedIdSet
                  .where((id) {
                    final text = store.texts[id];
                    if (text == null) return false;
                    return text.rootCategory.id == cat.id;
                  })
                  .map((id) => store.texts[id]!)
                  .toList();

              if (savedInGroup.isEmpty) continue;

              items.add(GroupHeaderWidget(label: cat.title));
              for (final boxText in savedInGroup) {
                items.add(SItemWidget(
                  title: boxText.title,
                  subtitle: boxText.category.title,
                  onTap: () => Get.toNamed(
                    Routes.readTextScreen,
                    arguments: {
                      'id': boxText.id,
                      'categoryTitle': boxText.category.title,
                      'title': boxText.title,
                      'content': boxText.content,
                      'author': boxText.author,
                    },
                  ),
                  onRemove: () => savedCtrl.toggle(boxText.id),
                ));
              }
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => items[i],
                childCount: items.length,
              ),
            );
          }),
        ],
      ),
    );
  }
}
