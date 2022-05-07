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

  TextSelectionDrawer({
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
            future: category == null
                ? widget.service.getIndex()
                : category.isPreview
                    ? widget.service
                        .fetchCategory(category, category.parentCategory)
                    : Future.value(category),
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                log.e("Error building drawer", snapshot.error,
                    snapshot.stackTrace);

                return Text("Error ${snapshot.error}");
              }

              final fetchedCategory = snapshot.data;
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              return Drawer(
                child: SafeArea(
                  child: (isLoading)
                      ? Center(
                          child: SpinKitThreeBounce(
                          color: Colors.white,
                          size: 24.0,
                        ))
                      : buildListView(
                          fetchedCategory!,
                          isIndex: category == null,
                        ),
                ),
              );
            });
      },
    );
  }

  Widget buildListView(PessoaCategory category, {required bool isIndex}) {
    final selectedTextLink = widget.selectedText?.link;
    final selectedCategoryLink = widget.selectedText?.category.link;

    final subcategories = category.subcategories.map((subcategory) => ListTile(
          horizontalTitleGap: 8.0,
          minLeadingWidth: 0.0,
          leading: Icon(Icons.subdirectory_arrow_right_rounded),
          title: Text(subcategory.title, style: bonitoTextTheme.headline4),
          selected: selectedCategoryLink != null
              ? subcategory.link == selectedCategoryLink
              : false,
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
          leading: Icon(Icons.text_snippet_rounded),
          title: Text(text.title, style: bonitoTextTheme.headline4),
          selected:
              selectedTextLink != null ? text.link == selectedTextLink : false,
          selectedColor: Colors.white,
          selectedTileColor: Colors.white10,
          onTap: () {
            setState(() {
              widget.selectionSink.add(text);
              Navigator.pop(context);
            });
      },
    ));

    return Column(
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
        if (!isIndex)
          ListTile(
              horizontalTitleGap: 8.0,
              minLeadingWidth: 0.0,
              leading: Icon(Icons.arrow_back_rounded),
              title: Text("Back", style: bonitoTextTheme.headline4),
              onTap: () {
                setState(() {
                  final previousCategory = category.parentCategory;
                  categoryStream.add(previousCategory);

                  if (previousCategory == null)
                    log.i("Backing to index");
                  else
                    log.i('Backing to previous category '
                        '"${previousCategory.title}"');
                });
              }),
      ],
    );
  }
}
