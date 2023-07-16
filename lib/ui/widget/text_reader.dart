import 'package:flutter/material.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/util/widget_extensions.dart';
import 'package:share_plus/share_plus.dart';

class TextReader extends StatelessWidget {
  final ScrollController _scrollController;
  final String categoryTitle;
  final PessoaText currentText;

  TextReader(
      {Key? key,
      ScrollController? scrollController,
      required this.categoryTitle,
      required this.currentText})
      : _scrollController =
            scrollController ?? ScrollController(keepScrollOffset: false),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Center(child: ReaderCategoryText(categoryTitle)),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: ReaderTitleText(currentText.title),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ReaderContentText(currentText),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
              child: Center(
                child: ReaderAuthorText(currentText.author),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReaderCategoryText extends StatelessWidget {
  final String category;

  const ReaderCategoryText(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      category,
      style: bonitoTextTheme.titleSmall,
    );
  }
}

class ReaderTitleText extends StatelessWidget {
  final String title;

  const ReaderTitleText(
    this.title, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: bonitoTextTheme.headlineSmall,
    );
  }
}

class ReaderContentText extends StatelessWidget {
  final PessoaText text;

  const ReaderContentText(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text.content,
      textAlign: TextAlign.left,
      style: bonitoTextTheme.bodyMedium,
      contextMenuBuilder: (ctx, state) {
        final String selectedText = state.getSelectedText();
        final List<ContextMenuButtonItem> buttonItems =
            state.contextMenuButtonItems;

        buttonItems.add(ContextMenuButtonItem(
          label: 'Share',
          onPressed: () {
            ContextMenuController.removeAny();
            Share.share('"$selectedText" - ${text.author}');
          },
        ));

        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: state.contextMenuAnchors,
          buttonItems: buttonItems,
        );
      },
    );
  }
}

class ReaderAuthorText extends StatelessWidget {
  final String author;

  const ReaderAuthorText(this.author, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      author,
      style: bonitoTextTheme.labelMedium,
    );
  }
}
