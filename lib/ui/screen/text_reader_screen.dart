import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/dto/box/box_person_text.dart';
import 'package:pessoa_pensadora/repository/history_store.dart';
import 'package:pessoa_pensadora/service/read_controller.dart';
import 'package:pessoa_pensadora/service/saved_controller.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/widget/button/arquivo_pessoa_button.dart';
import 'package:pessoa_pensadora/ui/widget/button/share_text_button.dart';
import 'package:pessoa_pensadora/ui/widget/reader/reader_nav_widget.dart';
import 'package:pessoa_pensadora/ui/widget/reader/text_reader.dart';

class TextReaderScreen extends StatelessWidget {
  static const routeName = '/textReader';

  const TextReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final int id = args['id'];
    final String text = args['content'];
    final String author = args['author'];
    final String categoryTitle = args['categoryTitle'];
    final String title = args['title'];

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
    final BoxPessoaText? prev =
        currentIdx > 0 ? siblings[currentIdx - 1] : null;
    final BoxPessoaText? next =
        currentIdx >= 0 && currentIdx < siblings.length - 1
            ? siblings[currentIdx + 1]
            : null;

    void navigateTo(BoxPessoaText boxText) {
      Get.off(
        () => const TextReaderScreen(),
        arguments: {
          'id': boxText.id,
          'categoryTitle': boxText.category.title,
          'title': boxText.title,
          'content': boxText.content,
          'author': boxText.author,
        },
        transition: Transition.noTransition,
        preventDuplicates: false,
      );
    }

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

    return Scaffold(
      backgroundColor: BonitoTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: BonitoTheme.bgSecondary,
        elevation: 0,
        scrolledUnderElevation: 0,
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
            readerNav: ReaderNavWidget(
              siblings: siblings,
              currentIdx: currentIdx,
              prev: prev,
              next: next,
              onNavigate: navigateTo,
            ),
          ),
        ),
      ),
    );
  }
}

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
