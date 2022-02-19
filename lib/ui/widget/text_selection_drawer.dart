import 'package:flutter/material.dart';
import 'package:pessoa_bonito/collection/Stack.dart';
import 'package:pessoa_bonito/service/arquivo_pessoa_service.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

class TextSelectionDrawer extends StatefulWidget {
  final ArquivoPessoaService service;

  final StackCollection<PessoaCategory> previousCategories;
  final PessoaCategory? initialCategory;

  final Function(PessoaCategory?) setCurrentCategoryCallback;
  final Function(PessoaText) setCurrentTextCallback;

  TextSelectionDrawer({
    Key? key,
    required this.service,
    required this.initialCategory,
    required this.setCurrentCategoryCallback,
    required this.setCurrentTextCallback,
  })  : previousCategories = StackCollection(),
        super(key: key);

  @override
  _TextSelectionDrawerState createState() => _TextSelectionDrawerState();
}

class _TextSelectionDrawerState extends State<TextSelectionDrawer> {
  PessoaCategory? currentCategory;

  double _currentScroll = 0.0;

  @override
  void initState() {
    super.initState();

    currentCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final scrollController =
        ScrollController(initialScrollOffset: _currentScroll);

    scrollController.addListener(() {
      _currentScroll = scrollController.offset;
    });

    return FutureBuilder(
        future: currentCategory == null
            ? widget.service.getIndex()
            : widget.service.fetchCategory(currentCategory!),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            log.e("Error building drawer", snapshot.error, snapshot.stackTrace);

            return Text("Error ${snapshot.error}");
          }

          if (!snapshot.hasData) return CircularProgressIndicator();

          final fetchedCategory = snapshot.data as PessoaCategory;

          final subcategories =
              fetchedCategory.subcategories?.map((subcategory) => ListTile(
                        horizontalTitleGap: 8.0,
                        minLeadingWidth: 0.0,
                        leading: Icon(Icons.subdirectory_arrow_right_rounded),
                        title: Text(subcategory.title,
                            style: bonitoTextTheme.headline4),
                        onTap: () {
                          setState(() {
                            if (currentCategory != null)
                              widget.previousCategories.push(fetchedCategory);

                            setCurrentCategory(subcategory);

                            log.i('Navigated to "${subcategory.title}"');
                          });
                        },
                      )) ??
                  [];

          final texts = fetchedCategory.texts.map((text) => ListTile(
                horizontalTitleGap: 8.0,
                minLeadingWidth: 0.0,
                leading: Icon(Icons.text_snippet_rounded),
                title: Text(text.title, style: bonitoTextTheme.headline4),
                onTap: () {
                  setState(() {
                    widget.setCurrentTextCallback(text);
                    Navigator.pop(context);
                  });
                },
              ));

          return Drawer(
              child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.only(top: 24.0),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          fetchedCategory.title,
                          style: bonitoTextTheme.headline3,
                        ),
                      ),
                      ...ListTile.divideTiles(
                        color: Colors.white70,
                        tiles: [...texts, ...subcategories],
                      ),
                    ],
                  ),
                ),
                if (currentCategory != null)
                  ListTile(
                      horizontalTitleGap: 8.0,
                      minLeadingWidth: 0.0,
                      leading: Icon(Icons.arrow_back_rounded),
                      title: Text("Back", style: bonitoTextTheme.headline4),
                      onTap: () {
                        setState(() {
                          final previousCategory =
                              widget.previousCategories.pop();

                          log.d('Setting current category to previous...');

                          setCurrentCategory(previousCategory);

                          if (previousCategory == null)
                            log.i("Backed to index");
                          else
                            log.i('Backed category to previous '
                                '"${previousCategory.title}"');
                        });
                      }),
              ],
            ),
          ));
        });
  }

  void setCurrentCategory(PessoaCategory? category) {
    currentCategory = category;
    widget.setCurrentCategoryCallback(category);
  }
}
