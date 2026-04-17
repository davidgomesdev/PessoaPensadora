import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/service/selection_action_service.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

const double _scrollThreshold = 10;
const _scrollHintGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0x00080808),
    Color(0xFF080808),
  ],
);

class TextReader extends StatefulWidget {
  final String title;
  final String content;
  final String author;
  final Widget? actions;
  final Widget? readerNav;

  const TextReader({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    this.actions,
    this.readerNav,
  });

  @override
  State<TextReader> createState() => _TextReaderState();
}

class _TextReaderState extends State<TextReader> {
  late final ScrollController _scrollController;
  final _isAtBottom = false.obs;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: false);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final isAtBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _scrollThreshold;
    if (_isAtBottom.value != isAtBottom) _isAtBottom.value = isAtBottom;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
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
                              widget.author.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                letterSpacing: 3.0,
                                color: BonitoTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.title,
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
                            if (widget.actions != null) widget.actions!,
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child:
                            ReaderContentText(widget.author, widget.content),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Obx(
                  () {
                    return IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _isAtBottom.value ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        height: 56,
                        decoration: const BoxDecoration(
                          gradient: _scrollHintGradient,
                        ),
                      ),
                    ),
                  );
                  },
                ),
              ),
            ],
          ),
        ),
        if (widget.readerNav != null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: BonitoTheme.borderCol)),
            ),
            child: widget.readerNav!,
          ),
      ],
    );
  }
}

class ReaderContentText extends StatefulWidget {
  final String author;
  final String text;

  const ReaderContentText(this.author, this.text, {super.key});

  @override
  State<ReaderContentText> createState() => _ReaderContentTextState();
}

class _ReaderContentTextState extends State<ReaderContentText> {
  final SelectionActionService _actionService = Get.find();
  String _selectedText = '';

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      onSelectionChanged: (value) {
        _selectedText = value?.plainText ?? '';
      },
      contextMenuBuilder: (ctx, state) {
        final List<ContextMenuButtonItem> buttonItems =
            state.contextMenuButtonItems;

        final isSingleWord =
            _selectedText.isNotEmpty && !_selectedText.contains(' ');

        if (isSingleWord) {
          buttonItems.add(_buildDefinitionButton(_selectedText));
        } else if (_selectedText.isNotEmpty) {
          buttonItems.add(_buildSearchButton(_selectedText));
          buttonItems.add(_buildShareButton(_selectedText));
        }

        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: state.contextMenuAnchors,
          buttonItems: buttonItems,
        );
      },
      child: Text(
        widget.text,
        textAlign: TextAlign.left,
        style: GoogleFonts.lora(
          fontSize: 17,
          height: 1.95,
          color: BonitoTheme.textPrimary,
        ),
      ),
    );
  }

  ContextMenuButtonItem _buildDefinitionButton(String selectedWord) {
    return ContextMenuButtonItem(
      label: '📖 Definir',
      onPressed: () {
        ContextMenuController.removeAny();
        _actionService.defineWord(selectedWord);
      },
    );
  }

  ContextMenuButtonItem _buildSearchButton(String selectedText) {
    return ContextMenuButtonItem(
      label: '🔍 Pesquisar',
      onPressed: () {
        ContextMenuController.removeAny();
        _actionService.searchOnline(selectedText);
      },
    );
  }

  ContextMenuButtonItem _buildShareButton(String selectedText) {
    return ContextMenuButtonItem(
      label: '📤 Partilhar',
      onPressed: () {
        ContextMenuController.removeAny();
        _actionService.shareQuote(selectedText, widget.author);
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
