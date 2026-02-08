import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/model/pessoa_category.dart';
import 'package:pessoa_pensadora/model/pessoa_text.dart';
import 'package:pessoa_pensadora/repository/read_store.dart';
import 'package:pessoa_pensadora/repository/reader_preference_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/widget/button/bug_report_button.dart';
import 'package:pessoa_pensadora/ui/widget/text_selection_drawer_list_view.dart';
import 'package:pessoa_pensadora/ui/widget/button/reading_type_button.dart';
import 'package:pessoa_pensadora/util/generic_extensions.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

import '../routes.dart';

class SearchFilter {
  String textFilter;
  SearchReadFilter readFilter;

  SearchFilter(this.readFilter) : textFilter = '';

  @override
  String toString() {
    return "textFilter=$textFilter;readFilter='${readFilter.label}'";
  }
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

class TextSelectionDrawer extends StatefulWidget {
  final PessoaCategory mainIndex, fullIndex;
  final PessoaText? selectedText;
  final Sink<PessoaText> selectionSink;
  final ScrollController scrollController;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ReaderPreferenceStore readerPreferenceStore;
  final void Function(bool) onFullReadingChange;

  const TextSelectionDrawer({
    super.key,
    required this.mainIndex,
    required this.fullIndex,
    required this.selectionSink,
    required this.selectedText,
    required this.scrollController,
    required this.scaffoldKey,
    required this.readerPreferenceStore,
    required this.onFullReadingChange,
  });

  @override
  State<TextSelectionDrawer> createState() => _TextSelectionDrawerState();
}

class _TextSelectionDrawerState extends State<TextSelectionDrawer> {
  final StreamController<PessoaCategory?> categoryStream =
      StreamController.broadcast();
  final StreamController<SearchFilter> searchFilterStream =
      StreamController.broadcast();
  final textEditingController = TextEditingController();
  final listScrollController = ScrollController();

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
          final category = snapshot.data ??
              ((widget.readerPreferenceStore.isFullReadingMode)
                  ? widget.fullIndex
                  : widget.mainIndex);

          searchFilterStream.add(SearchFilter(SearchReadFilter.all));
          textEditingController.text = '';

          return Drawer(
            child: SafeArea(
              child: StreamBuilder<SearchFilter>(
                  initialData: SearchFilter(SearchReadFilter.all),
                  stream: searchFilterStream.stream,
                  builder: (context, snapshot) {
                    final searchTextFilter =
                        snapshot.data ?? SearchFilter(SearchReadFilter.all);

                    if (snapshot.connectionState == ConnectionState.done) {
                      log.i('Current filter: $searchTextFilter');
                    }

                    return buildListView(category, searchTextFilter);
                  }),
            ),
          );
        });
  }

  Widget buildListView(PessoaCategory category, SearchFilter searchFilter) {
    final selectedCategory = widget.selectedText?.category!;
    final selectedTextId = widget.selectedText?.id;

    final subcategoryWidgets =
        category.subcategories.map((subcategory) => buildSubcategoryTile(
              subcategory,
              selectedCategory?.getParentTree() ?? [],
            ));

    final texts = category.texts;
    final filteredTexts = texts
        .where((text) => filterByContent(text, searchFilter.textFilter))
        .where((text) => filterByReadState(text, searchFilter.readFilter))
        .toList();

    final readRepo = Get.find<ReadRepository>();
    final readAndTotal = (
      texts.where((text) => readRepo.isTextRead(text.id)).length,
      texts.length
    );

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Column(
        children: [
          buildTitle(category),
          if (texts.isNotEmpty)
            buildFilters(filteredTexts.isNotEmpty, searchFilter, readAndTotal),
          Expanded(
            child: Material(
                child: DrawerListView(
              selectionSink: widget.selectionSink,
              scrollController: listScrollController,
              subcategories: subcategoryWidgets,
              texts: filteredTexts,
              selectedTextId: selectedTextId,
              onReadChange: () {
                setState(() {});
              },
            )),
          ),
          if (!category.isIndex) buildBackTile(category),
        ],
      ),
    );
  }

  Padding buildTitle(PessoaCategory category) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, right: 8.0).copyWith(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              category.title,
              style: bonitoTextTheme.displaySmall,
            ),
          ),
          Row(
            children: [
              // The FlutterFileDialog dialog isn't available on Web,
              // need to swap for FilePicker
              if (category.isIndex && !kIsWeb)
                BugReportButton(
                  scaffoldKey: widget.scaffoldKey,
                ),
              if (category.isIndex)
                ReadingTypeButton(
                  isFullReading: widget.readerPreferenceStore.isFullReadingMode,
                  onPress: (isFullReading) =>
                      widget.onFullReadingChange(isFullReading),
                ),
              IconButton(
                  tooltip: 'Textos marcados',
                  icon: const Icon(Icons.bookmarks),
                  onPressed: () {
                    Get.toNamed(Routes.savedScreen);
                  }),
              IconButton(
                  tooltip: 'Histórico',
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    Get.toNamed(Routes.historyScreen);
                  }),
            ],
          )
        ],
      ),
    );
  }

  Padding buildFilters(
      bool hasTexts, SearchFilter currentFilter, (int, int) readCount) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
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
                searchFilterStream
                    .add(currentFilter..textFilter = searchFilter);
              },
              controller: textEditingController,
            ),
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('${readCount.$1}/${readCount.$2}'),
              ),
            ),
          ),
          Flexible(
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
          ),
        ],
      ),
    );
  }

  ListTile buildSubcategoryTile(
      PessoaCategory subcategory, List<int> selectedCategoryTree) {
    return ListTile(
      horizontalTitleGap: 8.0,
      minLeadingWidth: 0.0,
      leading: const Icon(Icons.subdirectory_arrow_right_rounded),
      title: Text(subcategory.title, style: bonitoTextTheme.headlineMedium),
      selected: selectedCategoryTree.contains(subcategory.id),
      onTap: () {
        setState(() {
          if (listScrollController.hasClients) listScrollController.jumpTo(0);
          categoryStream.add(subcategory);

          log.i(
              'Navigated to "${subcategory.title}"${(subcategory.isFullIndex) ? "Full" : ""}');
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

  ListTile buildBackTile(PessoaCategory category) {
    return ListTile(
        horizontalTitleGap: 8.0,
        minLeadingWidth: 0.0,
        leading: const Icon(Icons.arrow_back_rounded),
        title: Text("Voltar", style: bonitoTextTheme.headlineMedium),
        tileColor: Colors.black26,
        onTap: () {
          setState(() {
            if (listScrollController.hasClients) listScrollController.jumpTo(0);

            final previousCategory = category.parentCategory;

            assert(previousCategory != null);

            if (previousCategory!.isIndex) {
              categoryStream.add(null);
              log.i(
                  "Backing to index ${(widget.readerPreferenceStore.isFullReadingMode) ? "(Full)" : "(Main)"}");
            } else {
              categoryStream.add(previousCategory);
              log.i('Backing to previous category "${previousCategory.title}"');
            }
          });
        });
  }
}
