import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/repository/read.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/util/action_feedback.dart';
import 'package:pessoa_bonito/util/generic_extensions.dart';
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

class SearchFilter {
  String textFilter;
  SearchReadFilter readFilter;

  SearchFilter(this.readFilter) : textFilter = '';
}

enum SearchReadFilter {
  all('Todos', Icons.book),
  unread('Apenas não lidos', Icons.chrome_reader_mode_outlined),
  read('Apenas lidos', Icons.chrome_reader_mode);

  final String label;
  final IconData icon;

  const SearchReadFilter(this.label, this.icon);

  SearchReadFilter next() =>
      SearchReadFilter.values.getNext(this) ?? SearchReadFilter.values.first;
}

extension SearchReadFilterExt on SearchReadFilter {
}

class _TextSelectionDrawerState extends State<TextSelectionDrawer> {
  StreamController<PessoaCategory?> categoryStream =
  StreamController.broadcast();
  StreamController<SearchFilter> searchFilterStream = StreamController
      .broadcast();
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
          searchFilterStream.add(SearchFilter(SearchReadFilter.all));
          textEditingController.text = '';

          return Drawer(
            child: SafeArea(
              child: StreamBuilder<SearchFilter>(
                  initialData: SearchFilter(SearchReadFilter.all),
                  stream: searchFilterStream.stream,
                  builder: (context, snapshot) {
                    final searchTextFilter = snapshot.data ??
                        SearchFilter(SearchReadFilter.all);

                    log.i('Current filter: $searchTextFilter');

                    return buildListView(category, searchTextFilter);
                  }),
            ),
          );
        });
  }

  Widget buildListView(PessoaCategory category, SearchFilter searchFilter) {
    final selectedCategoryId = widget.selectedText?.category!.id;
    final selectedTextId = widget.selectedText?.id;

    final subcategories = category.subcategories.map(
            (subcategory) =>
            buildSubcategoryTile(subcategory, selectedCategoryId));

    final texts = category.texts;
    final filteredTexts =
    texts.where((text) => filterByContent(text, searchFilter.textFilter))
        .where((text) => filterByReadState(text, searchFilter.readFilter)).toList();

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Column(
        children: [
          buildTitle(category),
          if (texts.isNotEmpty)
            buildFilters(filteredTexts.isNotEmpty, searchFilter),
          buildTilesList(subcategories, filteredTexts, selectedTextId),
          if (!category.isIndex) buildBackTile(category),
        ],
      ),
    );
  }

  Padding buildTitle(PessoaCategory category) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0).copyWith(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              category.title,
              style: bonitoTextTheme.displaySmall,
            ),
          ),
          Row(children: [
            IconButton(
              tooltip: 'Textos marcados',
              icon: const Icon(Icons.bookmarks),
              onPressed: () {
                Get.toNamed(Routes.savedScreen);
              },
              iconSize: 24.0,
              splashRadius: 24.0,
            ),
            IconButton(
              tooltip: 'Histórico',
              icon: const Icon(Icons.history),
              onPressed: () {
                Get.toNamed(Routes.historyScreen);
              },
              iconSize: 24.0,
              splashRadius: 24.0,
            ),
          ],)
        ],
      ),
    );
  }

  Padding buildFilters(bool hasTexts, SearchFilter currentFilter) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 6,
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
                searchFilterStream.add(
                    currentFilter..textFilter = searchFilter);
              },
              controller: textEditingController,
            ),
          ),
          Flexible(child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              tooltip: currentFilter.readFilter.label,
              icon: Icon(currentFilter.readFilter.icon),
              onPressed: () {
                searchFilterStream.add(currentFilter
                  ..readFilter = currentFilter.readFilter.next());
              },
              iconSize: 24.0,
              splashRadius: 24.0,
            ),
          ),)
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

  ListTile buildSubcategoryTile(PessoaCategory subcategory,
      int? selectedCategoryId) {
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

  bool filterByReadState(PessoaText text, SearchReadFilter filter) {
    if (filter == SearchReadFilter.all) return true;

    final isTextRead = Get.find<ReadRepository>().isTextRead(text.id);

    return (filter == SearchReadFilter.read && isTextRead) ||
        (filter == SearchReadFilter.unread && !isTextRead);
  }

  bool filterByContent(PessoaText text, String textFilter) {
    final filterWords = textFilter.toLowerCase().split(' ');
    final contentInLowercase = text.content.toLowerCase();

    return filterWords.every((keyword) => contentInLowercase.contains(keyword));
  }

  ListTile buildTextTile(PessoaText text, int? selectedTextId) {
    final isTextRead = Get.find<ReadRepository>().isTextRead(text.id);

    return ListTile(
      horizontalTitleGap: 8.0,
      minLeadingWidth: 0.0,
      leading: const Icon(Icons.text_snippet_rounded),
      title: Text(text.title, style: bonitoTextTheme.headlineMedium),
      textColor: (isTextRead) ? Colors.white60 : Colors.white,
      selected: text.id == selectedTextId,
      selectedColor: (isTextRead) ? Colors.white60 : Colors.white,
      selectedTileColor: Colors.white10,
      onTap: () {
        setState(() {
          widget.selectionSink.add(text);
          Navigator.pop(context);
        });
      },
      onLongPress: () {
        setState(() {
          ReadRepository readRepository = Get.find();

          readRepository.toggleRead(text.id);
          ActionFeedback.lightHaptic();
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
