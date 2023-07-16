import 'package:flutter/material.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';

final ScrollController _scrollController =
    ScrollController(keepScrollOffset: false);

class TextReader extends StatelessWidget {
  final String categoryTitle;
  final PessoaText currentText;

  const TextReader(
      {Key? key, required this.categoryTitle, required this.currentText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutQuart,
      );
    }

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
              child: ReaderContentText(currentText.content),
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
  final String content;

  const ReaderContentText(
    this.content, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      content,
      textAlign: TextAlign.left,
      style: bonitoTextTheme.bodyMedium,
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
