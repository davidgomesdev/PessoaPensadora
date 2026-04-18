import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/repository/history_store.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/widget/text_list_item_widget.dart';
import 'text_reader_screen.dart';

class HistoryScreen extends StatelessWidget {
  static const routeName = '/history';

  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStoreService store = Get.find();
    final HistoryRepository repository = Get.find();

    return Scaffold(
      backgroundColor: BonitoTheme.bgPrimary,
      body: Obx(() {
        final ids = repository.historyIds.toList();

        if (ids.isEmpty) {
          return Center(
            child: Text(
              'Nenhum texto visitado',
              style: GoogleFonts.inter(
                  fontSize: 14, color: BonitoTheme.textMuted),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final boxText = store.texts[ids[i]];
                  if (boxText == null) return const SizedBox.shrink();
                  return TextListItemWidget(
                    title: boxText.title,
                    subtitle: boxText.category.title,
                    trailing: '',
                    onTap: () => Get.toNamed(
                      TextReaderScreen.routeName,
                      arguments: {
                        'id': boxText.id,
                        'textIndex': i,
                        'filteredCategoryTexts': ids,
                        'categoryTitle': boxText.category.title,
                        'title': boxText.title,
                        'content': boxText.content,
                        'author': boxText.author,
                      },
                    ),
                  );
                },
                childCount: ids.length,
              ),
            ),
          ],
        );
      }),
    );
  }
}
