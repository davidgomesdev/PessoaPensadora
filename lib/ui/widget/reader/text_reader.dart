import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/service/selection_action_service.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/util/widget_extensions.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TextReader extends StatelessWidget {
  final ScrollController _scrollController;
  final String categoryTitle;
  final String title;
  final String content;
  final String author;

  final Widget? actions;

  final Widget? readerNav;

  TextReader({
    super.key,
    ScrollController? scrollController,
    required this.categoryTitle,
    required this.title,
    required this.content,
    required this.author,
    this.actions,
    this.readerNav,
  }) : _scrollController =
            scrollController ?? ScrollController(keepScrollOffset: false);

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: SingleChildScrollView(
        controller: _scrollController,

        padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Container(
              padding: const EdgeInsets.only(bottom: 24),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: BonitoTheme.borderCol),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Text(
                    author.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      letterSpacing: 3.0,
                      color: BonitoTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: BonitoTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: 36,
                    height: 1,
                    color: BonitoTheme.goldDim,
                  ),
                  const SizedBox(height: 16),

                  if (actions != null) actions!,
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ReaderContentText(author, content),
            ),

            if (readerNav != null) ...[
              Container(
                margin: const EdgeInsets.only(top: 22),
                padding: const EdgeInsets.only(top: 22),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: BonitoTheme.borderCol)),
                ),
                child: readerNav!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ReaderContentText extends StatelessWidget {
  final SelectionActionService _actionService = Get.find();

  final String author;
  final String text;

  ReaderContentText(
    this.author,
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      textAlign: TextAlign.left,
      style: GoogleFonts.lora(
        fontSize: 17,
        height: 1.95,
        color: BonitoTheme.textPrimary,
      ),
      contextMenuBuilder: (ctx, state) {
        final String selectedText = state.getSelectedText();
        final List<ContextMenuButtonItem> buttonItems =
            state.contextMenuButtonItems;

        final isSingleWord = !selectedText.contains(' ');

        if (isSingleWord) {
          buttonItems.add(buildDefinitionButton(selectedText));
        } else {
          buttonItems.add(buildSearchButton(selectedText));
          buttonItems.add(buildShareButton(selectedText));
        }

        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: state.contextMenuAnchors,
          buttonItems: buttonItems,
        );
      },
    );
  }

  ContextMenuButtonItem buildDefinitionButton(String selectedWord) {
    return ContextMenuButtonItem(
        label: '📖 Definir',
        onPressed: () {
          ContextMenuController.removeAny();
          _actionService.defineWord(selectedWord);
        });
  }

  ContextMenuButtonItem buildSearchButton(String selectedText) {
    return ContextMenuButtonItem(
        label: '🔍 Pesquisar',
        onPressed: () {
          ContextMenuController.removeAny();
          _actionService.searchOnline(selectedText);
        });
  }

  ContextMenuButtonItem buildShareButton(String selectedText) {
    return ContextMenuButtonItem(
      label: '📤 Partilhar',
      onPressed: () {
        ContextMenuController.removeAny();
        _actionService.shareQuote(selectedText, author);
      },
    );
  }
}

class ReaderCategoryText extends StatelessWidget {
  final String category;
  const ReaderCategoryText(this.category, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        category,
        style: GoogleFonts.inter(
          fontSize: 10,
          letterSpacing: 3.0,
          color: BonitoTheme.textMuted,
        ),
      );
}

class ReaderTitleText extends StatelessWidget {
  final String title;
  const ReaderTitleText(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          color: BonitoTheme.textPrimary,
        ),
      );
}

class ReaderAuthorText extends StatelessWidget {
  final String author;
  const ReaderAuthorText(this.author, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        author.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          letterSpacing: 3.0,
          color: BonitoTheme.textMuted,
        ),
      );
}
