import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/dto/box/box_person_text.dart';
import 'package:pessoa_bonito/model/saved_text.dart';
import 'package:pessoa_bonito/repository/save.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

import '../routes.dart';

class SavedTextsScreen extends StatelessWidget {
  const SavedTextsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SaveRepository repository = Get.find();
    final bookmarkedTexts = repository.getTexts();

    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
        slivers: [
          SliverAppBar(
            title: Text("Textos marcados", style: bonitoTextTheme.displaySmall),
            pinned: true,
          ),
          SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              sliver: _SavedTextsSliverList(
                bookmarkedTexts: bookmarkedTexts,
                onDismiss: (text) {
                  repository.deleteText(text.id);
                },
              )),
        ],
      ),
    );
  }
}

class _SavedTextsSliverList extends StatelessWidget {
  final List<SavedText> bookmarkedTexts;
  final void Function(SavedText) onDismiss;

  const _SavedTextsSliverList(
      {required this.bookmarkedTexts, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemBuilder: (context, index) {
        final text = bookmarkedTexts[index];

        return Dismissible(
          key: Key(text.id.toString()),
          onDismissed: (direction) {
            onDismiss(text);
          },
          confirmDismiss: (direction) => displayUndoSnackbar(context),
          direction: DismissDirection.endToStart,
          dragStartBehavior: DragStartBehavior.down,
          background: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Align(
                child: Icon(
                  Icons.delete_forever,
                  size: 36.0,
                  color: Colors.yellowAccent,
                ),
                alignment: Alignment.centerRight),
          ),
          child: _SavedTextTile(text.toModel()),
        );
      },
      itemCount: bookmarkedTexts.length,
    );
  }

  /// Returns whether or not the action was accepted.
  Future<bool> displayUndoSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text('Removido dos textos marcados'),
      action: SnackBarAction(
          label: 'Cancelar',
          onPressed: () {
            log.i('Snackbar undo bookmarked text pressed.');
          }),
    );

    return ScaffoldMessenger.of(context)
        .showSnackBar(snackBar)
        .closed
        .then((closeReason) {
      if (closeReason == SnackBarClosedReason.action) {
        log.i('Bookmarked text removal was cancelled.');
        return false;
      }

      return true;
    });
  }
}

class _SavedTextTile extends StatelessWidget {
  final BoxPessoaText text;

  const _SavedTextTile(this.text);

  @override
  Widget build(BuildContext context) {
    var textCondensed = text.content.replaceAll("\n\n", "\n").trim();

    return ListTile(
      enableFeedback: true,
      title: Text(
        text.title,
        style:
            bonitoTextTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textCondensed,
              style: bonitoTextTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  text.author,
                  textAlign: TextAlign.right,
                  style: bonitoTextTheme.labelSmall,
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Get.toNamed(Routes.readTextScreen, arguments: {
          "categoryTitle": text.category.title,
          "title": text.title,
          "content": text.content,
          "author": text.author,
        });
      },
    );
  }
}
