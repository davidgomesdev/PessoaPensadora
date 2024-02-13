import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/dto/box/box_person_category.dart';
import 'package:pessoa_bonito/dto/box/box_person_text.dart';
import 'package:pessoa_bonito/repository/collapsable_store.dart';
import 'package:pessoa_bonito/repository/saved_store.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

import '../routes.dart';

class SavedTextsScreen extends StatefulWidget {
  const SavedTextsScreen({super.key});

  @override
  State<SavedTextsScreen> createState() => _SavedTextsScreenState();
}

class _SavedTextsScreenState extends State<SavedTextsScreen> {
  @override
  Widget build(BuildContext context) {
    final SaveRepository repository = Get.find();
    final savedTexts = repository.getTexts().map((e) => e.toModel());
    final bookmarkedTexts = groupBy<BoxPessoaText, BoxPessoaCategory>(
        savedTexts, (text) => text.rootCategory);

    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
        slivers: [
          SliverAppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Textos marcados", style: bonitoTextTheme.displaySmall)
              ],
            ),
            pinned: true,
          ),
          SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              sliver: _SavedTextsSliverList(
                bookmarkedTexts: bookmarkedTexts,
                onDismiss: (textId) {
                  setState(() {
                    repository.deleteText(textId);
                  });
                },
              )),
        ],
      ),
    );
  }
}

class _SavedTextsSliverList extends StatelessWidget {
  final Map<BoxPessoaCategory, List<BoxPessoaText>> bookmarkedTexts;
  final ValueChanged<int> onDismiss;

  const _SavedTextsSliverList(
      {required this.bookmarkedTexts, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final entries =
        bookmarkedTexts.entries.sortedBy((element) => element.key.title);

    return SliverList.builder(
      itemBuilder: (_, index) {
        final textsByCategory = entries.elementAt(index);

        return _CategoryGroupTile(
            textsByCategory.key, textsByCategory.value, onDismiss);
      },
      itemCount: bookmarkedTexts.length,
    );
  }
}

class _CategoryGroupTile extends StatefulWidget {
  final BoxPessoaCategory category;
  final List<BoxPessoaText> texts;
  final ValueChanged<int> onDismiss;

  const _CategoryGroupTile(this.category, this.texts, this.onDismiss);

  @override
  State<_CategoryGroupTile> createState() => _CategoryGroupTileState();
}

class _CategoryGroupTileState extends State<_CategoryGroupTile> {
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();

    final CollapsableRepository repository = Get.find();
    isExpanded = repository.isExpanded(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.category.title),
      trailing: Icon(
        isExpanded
            ? Icons.arrow_drop_down_circle_outlined
            : Icons.arrow_drop_down_circle_rounded,
      ),
      collapsedIconColor: bonitoTheme.primaryColor,
      initiallyExpanded: isExpanded,
      onExpansionChanged: (newStatus) {
        setState(() {
          final CollapsableRepository repository = Get.find();

          repository.setStatus(widget.category.id, isExpanded = newStatus);
        });
      },
      children: widget.texts
          .map(
            (text) => _SavedTextTile(text, widget.onDismiss),
          )
          .toList(growable: false),
    );
  }
}

class _SavedTextTile extends StatelessWidget {
  final BoxPessoaText text;
  final ValueChanged<int> onDismiss;

  const _SavedTextTile(this.text, this.onDismiss);

  @override
  Widget build(BuildContext context) {
    var textCondensed = text.content.replaceAll("\n\n", "\n").trim();

    return Dismissible(
      key: Key(text.id.toString()),
      onDismissed: (_) => onDismiss(text.id),
      confirmDismiss: (direction) => displayUndoSnackbar(context),
      direction: DismissDirection.endToStart,
      dragStartBehavior: DragStartBehavior.down,
      dismissThresholds: const {DismissDirection.endToStart: 0.6},
      background: Stack(
        children: [
          Container(
            color: Colors.amber,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Align(
                child: Icon(
                  Icons.delete_forever,
                  size: 42.0,
                  color: Colors.white,
                ),
                alignment: Alignment.centerRight),
          ),
        ],
      ),
      child: ListTile(
        enableFeedback: true,
        title: Text(
          text.title,
          style: bonitoTextTheme.titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
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
      ),
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
      duration: Durations.extralong4,
    );

    return ScaffoldMessenger.of(context)
        .showSnackBar(snackBar)
        .closed
        .then((closeReason) {
      if (closeReason == SnackBarClosedReason.action) {
        log.i('Bookmarked text removal was cancelled');
        return false;
      }

      return true;
    });
  }
}
