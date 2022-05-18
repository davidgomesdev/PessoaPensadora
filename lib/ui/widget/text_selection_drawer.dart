import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/service/arquivo_pessoa_service.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

class TextSelectionDrawer extends StatefulWidget {
  final ArquivoPessoaService service;
  final PessoaText? selectedText;
  final Sink<PessoaText> selectionSink;

  const TextSelectionDrawer({
    Key? key,
    required this.selectionSink,
    required this.service,
    required this.selectedText,
  }) : super(key: key);

  @override
  _TextSelectionDrawerState createState() => _TextSelectionDrawerState();
}

class _TextSelectionDrawerState extends State<TextSelectionDrawer> {
  StreamController<PessoaCategory?> categoryStream =
      StreamController.broadcast();

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
        final category = snapshot.data;

        return FutureBuilder<PessoaCategory>(
            future: _getCategory(category),
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                log.e("Error building drawer", snapshot.error,
                    snapshot.stackTrace);

                return Text("Error ${snapshot.error}");
              }

              final fetchedCategory = snapshot.data;
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              if (!isLoading && fetchedCategory == null) {
                log.w("Fetched category is null after loading!");
                return Container();
              }

              return Drawer(
                child: SafeArea(
                  child: (isLoading)
                      ? const Center(
                          child: SpinKitThreeBounce(
                          color: Colors.white,
                          size: 24.0,
                        ))
                      : buildListView(fetchedCategory!),
                ),
              );
            });
      },
    );
  }

  Future<PessoaCategory> _getCategory(PessoaCategory? category) {
    if (category == null) return widget.service.getIndex();

    if (category.type == CategoryType.Preview) {
      return widget.service.fetchCategory(category, category.parentCategory);
    }

    return Future.value(category);
  }

  Widget buildListView(PessoaCategory category) {
    final selectedTextLink = widget.selectedText?.link;
    final selectedCategoryLink = widget.selectedText?.category.link;

    final subcategories = category.subcategories.map((subcategory) => ListTile(
      horizontalTitleGap: 8.0,
          minLeadingWidth: 0.0,
          leading: const Icon(Icons.subdirectory_arrow_right_rounded),
          title: Text(subcategory.title, style: bonitoTextTheme.headline4),
          selected: subcategory.link == selectedCategoryLink,
          selectedColor: Colors.white,
          selectedTileColor: Colors.white10,
          onTap: () {
            setState(() {
              categoryStream.add(subcategory);

              log.i('Navigated to "${subcategory.title}"');
            });
          },
        ));

    final texts = category.texts.map((text) => ListTile(
      horizontalTitleGap: 8.0,
          minLeadingWidth: 0.0,
          leading: const Icon(Icons.text_snippet_rounded),
          title: Text(text.title, style: bonitoTextTheme.headline4),
          selected: text.link == selectedTextLink,
          selectedColor: Colors.white,
          selectedTileColor: Colors.white10,
          onTap: () {
            setState(() {
              widget.selectionSink.add(text);
              Navigator.pop(context);
            });
          },
        ));

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0)
                .copyWith(top: 16.0, bottom: 12.0),
            child: Text(
              category.title,
              style: bonitoTextTheme.headline3,
            ),
          ),
          Expanded(
            child: ListView(
              controller: ScrollController(),
              children: [
                ...ListTile.divideTiles(
                  color: Colors.white70,
                  tiles: [...subcategories, ...texts],
                ),
              ],
            ),
          ),
          if (category.type != CategoryType.Index)
            ListTile(
                horizontalTitleGap: 8.0,
                minLeadingWidth: 0.0,
                leading: const Icon(Icons.arrow_back_rounded),
                title: Text("Voltar", style: bonitoTextTheme.headline4),
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
                }),
        ],
      ),
    );
  }
}
