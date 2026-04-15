import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/service/saved_controller.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/widget/group_header_widget.dart';
import 'package:pessoa_pensadora/ui/widget/s_item_widget.dart';
import 'text_reader_screen.dart';

class SavedTextsScreen extends StatelessWidget {
  static const routeName = '/saved';

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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16.0,
                    children: [
                      Flexible(
                        child: Text(
                          'Pessoa tem tantos textos incríveis, ainda não gostaste de nenhum? :(',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: BonitoTheme.textMuted),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          'Para guardar um texto, basta clicar no ícone de coração quando estiveres a ler um texto.',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: BonitoTheme.textMuted),
                        ),
                      ),
                    ],
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
                items.add(TextListItemWidget(
                  title: boxText.title,
                  subtitle: boxText.category.title,
                  onTap: () => Get.toNamed(
                    TextReaderScreen.routeName,
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
