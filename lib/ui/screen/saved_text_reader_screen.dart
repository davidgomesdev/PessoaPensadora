import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/repository/history_store.dart';
import 'package:pessoa_pensadora/service/read_controller.dart';
import 'package:pessoa_pensadora/service/saved_controller.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/widget/button/arquivo_pessoa_button.dart';
import 'package:pessoa_pensadora/ui/widget/button/share_text_button.dart';
import 'package:pessoa_pensadora/ui/widget/reader/text_reader.dart';

class TextReaderScreen extends StatelessWidget {
  const TextReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final int id = args['id'];
    final String text = args['content'];
    final String author = args['author'];
    final String categoryTitle = args['categoryTitle'];
    final String title = args['title'];

    // Mark as read when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Get.find<ReadController>().markRead(id);
        Get.find<HistoryRepository>().saveVisit(id);
      } catch (_) {}
    });

    final readCtrl = Get.find<ReadController>();
    final savedCtrl = Get.find<SavedController>();

    return Scaffold(
      backgroundColor: BonitoTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: BonitoTheme.bgSecondary,
        elevation: 0,
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  savedCtrl.isSaved(id) ? Icons.bookmark : Icons.bookmark_outline,
                  color: savedCtrl.isSaved(id) ? BonitoTheme.gold : BonitoTheme.textDim,
                ),
                onPressed: () => savedCtrl.toggle(id),
              )),
          ArquivoPessoaButton(textId: id),
          ShareTextButton(text: text, author: author),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Read marker row
            Obx(() => Container(
                  color: BonitoTheme.bgSecondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        readCtrl.isRead(id)
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: readCtrl.isRead(id)
                            ? BonitoTheme.greenTone
                            : BonitoTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => readCtrl.toggle(id),
                        child: Text(
                          readCtrl.isRead(id)
                              ? 'Marcado como lido'
                              : 'Marcar como lido',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: readCtrl.isRead(id)
                                ? BonitoTheme.greenTone
                                : BonitoTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: TextReader(
                  categoryTitle: categoryTitle,
                  title: title,
                  content: text,
                  author: author,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
