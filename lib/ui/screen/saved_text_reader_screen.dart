import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/dto/box/box_person_text.dart';
import 'package:pessoa_pensadora/repository/history_store.dart';
import 'package:pessoa_pensadora/service/read_controller.dart';
import 'package:pessoa_pensadora/service/saved_controller.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/routes.dart';
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
    final store = Get.find<TextStoreService>();

    // Compute sibling texts for prev/next navigation
    final textData = store.texts[id];
    final List<BoxPessoaText> siblings = textData != null
        ? store.texts.values
            .where((t) => t.categoryId == textData.categoryId)
            .toList()
        : [];
    final int currentIdx = siblings.indexWhere((t) => t.id == id);
    final BoxPessoaText? prev = currentIdx > 0 ? siblings[currentIdx - 1] : null;
    final BoxPessoaText? next =
        currentIdx >= 0 && currentIdx < siblings.length - 1
            ? siblings[currentIdx + 1]
            : null;

    void navigateTo(BoxPessoaText boxText) {
      Get.toNamed(
        Routes.readTextScreen,
        arguments: {
          'id': boxText.id,
          'categoryTitle': boxText.category.title,
          'title': boxText.title,
          'content': boxText.content,
          'author': boxText.author,
        },
        preventDuplicates: false,
      );
    }

    // Action buttons (read / save) — reactive
    final actionsWidget = Obx(() {
      final isRead = readCtrl.isRead(id);
      final isSaved = savedCtrl.isSaved(id);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ReaderBtn(
            label: isRead ? '✓  Lido' : '○  Marcar como Lido',
            isActive: isRead,
            activeColor: BonitoTheme.greenTone,
            activeBorderColor: const Color(0xFF444444),
            onTap: () => readCtrl.toggle(id),
          ),
          const SizedBox(width: 8),
          _ReaderBtn(
            label: isSaved ? '♥  Guardado' : '♡  Guardar',
            isActive: isSaved,
            activeColor: BonitoTheme.gold,
            activeBorderColor: BonitoTheme.goldDim,
            onTap: () => savedCtrl.toggle(id),
          ),
        ],
      );
    });

    // Prev / next navigation row
    final navWidget = siblings.isNotEmpty
        ? Row(
            children: [
              // prev button — left-aligned, max 42 % of row
              Expanded(
                flex: 42,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _NavBtn(
                    label: '← ${prev?.title ?? "Anterior"}',
                    enabled: prev != null,
                    onTap: () { if (prev != null) navigateTo(prev); },
                  ),
                ),
              ),
              // position indicator — centred
              Expanded(
                flex: 16,
                child: Center(
                  child: Text(
                    currentIdx >= 0
                        ? '${currentIdx + 1} / ${siblings.length}'
                        : '',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: BonitoTheme.textMuted,
                    ),
                  ),
                ),
              ),
              // next button — right-aligned, max 42 % of row
              Expanded(
                flex: 42,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _NavBtn(
                    label: '${next?.title ?? "Seguinte"} →',
                    enabled: next != null,
                    onTap: () { if (next != null) navigateTo(next); },
                  ),
                ),
              ),
            ],
          )
        : null;

    return Scaffold(
      backgroundColor: BonitoTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: BonitoTheme.bgSecondary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: BonitoTheme.borderCol, height: 1.0),
        ),
        actions: [
          ArquivoPessoaButton(textId: id),
          ShareTextButton(text: text, author: author),
        ],
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: TextReader(
            categoryTitle: categoryTitle,
            title: title,
            content: text,
            author: author,
            actions: actionsWidget,
            readerNav: navWidget,
          ),
        ),
      ),
    );
  }
}

// ── _ReaderBtn ────────────────────────────────────────────────────────────────

class _ReaderBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color activeBorderColor;
  final VoidCallback onTap;

  const _ReaderBtn({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeBorderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: BonitoTheme.bgSecondary,
          border: Border.all(
            color: isActive ? activeBorderColor : BonitoTheme.borderCol,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            letterSpacing: 0.4,
            color: isActive ? activeColor : BonitoTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

// ── _NavBtn ───────────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavBtn({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.25,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 160),
          decoration: BoxDecoration(
            color: BonitoTheme.bgSecondary,
            border: Border.all(color: BonitoTheme.borderCol),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: BonitoTheme.textDim,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
