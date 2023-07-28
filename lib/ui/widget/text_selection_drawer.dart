import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

import '../routes.dart';

class TextSelectionDrawer extends StatefulWidget {
  final PessoaCategory index;
  final PessoaText? selectedText;
  final Sink<PessoaText> selectionSink;

  const TextSelectionDrawer({
    Key? key,
    required this.index,
    required this.selectionSink,
    required this.selectedText,
  }) : super(key: key);

  @override
  _TextSelectionDrawerState createState() => _TextSelectionDrawerState();
}

class _TextSelectionDrawerState extends State<TextSelectionDrawer> {
  StreamController<PessoaCategory?> categoryStream =
      StreamController.broadcast();
  StreamController<String> searchFilterStream = StreamController.broadcast();
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    categoryStream.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PessoaCategory?>(
        initialData: widget.selectedText?.category,
        stream: categoryStream.stream,
        builder: (ctx, snapshot) {
          final category = snapshot.data ?? widget.index;
          searchFilterStream.add('');
          textEditingController.text = '';

          return Drawer(
            child: SafeArea(
              child: StreamBuilder<String>(
                  initialData: '',
                  stream: searchFilterStream.stream,
                  builder: (context, snapshot) {
                    final searchTextFilter = snapshot.data ?? '';

                    log.i('Current filter: $searchTextFilter');

                    return buildListView(category, searchTextFilter);
                  }),
            ),
          );
        });
  }

  Widget buildListView(PessoaCategory category, String textFilter) {
    final selectedCategoryId = widget.selectedText?.category!.id;
    final selectedTextId = widget.selectedText?.id;

    final subcategories = category.subcategories.map(
        (subcategory) => buildSubcategoryTile(subcategory, selectedCategoryId));

    final texts = category.texts;
    final filteredTexts =
        texts.where((text) => filterByContent(text, textFilter)).toList();

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Column(
        children: [
          buildTitle(category),
          if (texts.isNotEmpty)
            buildSearch(filteredTexts.isNotEmpty, textFilter),
          buildTilesList(subcategories, filteredTexts, selectedTextId),
          if (!category.isIndex) buildBackTile(category),
        ],
      ),
    );
  }

  Padding buildTitle(PessoaCategory category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              category.title,
              style: bonitoTextTheme.displaySmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: () {
              Get.toNamed(Routes.savedScreen);
            },
            iconSize: 24.0,
            splashRadius: 24.0,
          ),
        ],
      ),
    );
  }

  Padding buildSearch(bool hasTexts, String currentFilter) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            autocorrect: false,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8.0),
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Icon(Icons.search_rounded, size: 24.0),
              ),
              isDense: true,
              prefixIconConstraints: const BoxConstraints(minWidth: 36.0),
              errorText: hasTexts ? null : '',
              errorStyle: const TextStyle(height: 0),
            ),
            cursorOpacityAnimates: true,
            onChanged: (searchFilter) {
              searchFilterStream.add(searchFilter);
            },
            controller: textEditingController,
          ))
        ],
      ),
    );
  }

  Expanded buildTilesList(Iterable<ListTile> subcategories,
      List<PessoaText> texts, int? selectedTextId) {
    return Expanded(
      child: Material(
        child: ListView(
          controller: ScrollController(),
          children: [
            ...ListTile.divideTiles(
              color: Colors.white,
              tiles: [
                ...subcategories,
                ...texts.map((text) => buildTextTile(text, selectedTextId))
              ],
            ),
          ],
        ),
      ),
    );
  }

  ListTile buildSubcategoryTile(
      PessoaCategory subcategory, int? selectedCategoryId) {
    return ListTile(
      horizontalTitleGap: 8.0,
      minLeadingWidth: 0.0,
      leading: const Icon(Icons.subdirectory_arrow_right_rounded),
      title: Text(subcategory.title, style: bonitoTextTheme.headlineMedium),
      selected: subcategory.id == selectedCategoryId,
      onTap: () {
        setState(() {
          categoryStream.add(subcategory);

          log.i('Navigated to "${subcategory.title}"');
        });
      },
    );
  }

  bool filterByContent(PessoaText text, String textFilter) {
    final filterWords = textFilter.toLowerCase().split(' ');
    final contentInLowercase = text.content.toLowerCase();

    return filterWords.every((keyword) => contentInLowercase.contains(keyword));
  }

  ListTile buildTextTile(PessoaText text, int? selectedTextId) {
    return ListTile(
      horizontalTitleGap: 8.0,
      minLeadingWidth: 0.0,
      leading: const Icon(Icons.text_snippet_rounded),
      title: Text(text.title, style: bonitoTextTheme.headlineMedium),
      selected: text.id == selectedTextId,
      selectedColor: Colors.white,
      selectedTileColor: Colors.white10,
      onTap: () {
        setState(() {
          widget.selectionSink.add(text);
          Navigator.pop(context);
        });
      },
    );
  }

  ListTile buildBackTile(PessoaCategory category) {
    return ListTile(
        horizontalTitleGap: 8.0,
        minLeadingWidth: 0.0,
        leading: const Icon(Icons.arrow_back_rounded),
        title: Text("Voltar", style: bonitoTextTheme.headlineMedium),
        tileColor: Colors.black26,
        onTap: () {
          setState(() {
            final previousCategory = category.parentCategory;
            categoryStream.add(previousCategory);

            if (previousCategory == null) {
              log.i("Backing to index");
            } else {
              log.i('Backing to previous category '
                  '"${previousCategory.title}"');
            }
          });
        });
  }
}
