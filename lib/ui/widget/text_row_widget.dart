import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/model/pessoa_text.dart';
import 'package:pessoa_pensadora/service/read_controller.dart';
import 'package:pessoa_pensadora/service/saved_controller.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/routes.dart';

class TextRowWidget extends StatelessWidget {
  final PessoaText text;
  final int index;

  const TextRowWidget({
    super.key,
    required this.text,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final readCtrl = Get.find<ReadController>();
    final savedCtrl = Get.find<SavedController>();

    return InkWell(
      onTap: () => Get.toNamed(Routes.readTextScreen, arguments: {
        'id': text.id,
        'categoryTitle': text.category?.title ?? '',
        'title': text.title,
        'content': text.content,
        'author': text.author,
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: BonitoTheme.borderCol, width: 1),
          ),
        ),
        child: Row(
          children: [
            Obx(() => Icon(
                  Icons.circle,
                  size: 10,
                  color: readCtrl.isRead(text.id)
                      ? BonitoTheme.greenTone
                      : BonitoTheme.borderMid,
                )),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: BonitoTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => GestureDetector(
                  onTap: () => savedCtrl.toggle(text.id),
                  child: Icon(
                    savedCtrl.isSaved(text.id)
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    size: 20,
                    color: savedCtrl.isSaved(text.id)
                        ? BonitoTheme.gold
                        : BonitoTheme.textMuted,
                  ),
                )),
            const SizedBox(width: 12),
            Obx(() => GestureDetector(
                  onTap: () => readCtrl.toggle(text.id),
                  child: Icon(
                    readCtrl.isRead(text.id)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: readCtrl.isRead(text.id)
                        ? BonitoTheme.greenTone
                        : BonitoTheme.textMuted,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

