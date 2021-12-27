import 'package:flutter/material.dart';
import 'package:pessoa_bonito/collection/Stack.dart';
import 'package:pessoa_bonito/service/arquivo_pessoa_service.dart';

import '../bonito_theme.dart';

class ReaderScreen extends StatefulWidget {
  final ArquivoPessoaService service;

  ReaderScreen({Key? key})
      : service = ArquivoPessoaService(),
        super(key: key);

  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with SingleTickerProviderStateMixin {
  StackCollection<PessoaCategory> previousCategories;
  PessoaCategory? currentCategory;
  PessoaText? currentText;
  bool isInIndex = true;

  _ReaderScreenState()
      : previousCategories = StackCollection(),
        super();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: FutureBuilder(
        future: currentCategory == null
            ? widget.service.getIndex()
            : widget.service.fetchCategory(currentCategory!),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) return Text("Error ${snapshot.error}");

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
                            previousCategories.push(fetchedCategory);
                            currentCategory = subcategory;
                            isInIndex = false;
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
                    currentText = text;
                    Navigator.pop(context);
                  });
                },
              ));

          return Drawer(
              child: SafeArea(
            child: ListView(
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
                  tiles: [
                    ...texts,
                    ...subcategories,
                    if (previousCategories.isNotEmpty)
                      ListTile(
                          horizontalTitleGap: 8.0,
                          minLeadingWidth: 0.0,
                          leading: Icon(Icons.arrow_back_rounded),
                          title: Text("Back", style: bonitoTextTheme.headline4),
                          onTap: () {
                            setState(() {
                              final previousCategory =
                                  previousCategories.pop()!;

                              isInIndex = previousCategories.isEmpty;

                              currentCategory =
                                  isInIndex ? null : previousCategory;
                            });
                          }),
                  ],
                ),
              ],
            ),
          ));
        },
      ),
      body: Container(
        child: () {
          final currentText = this.currentText;

          if (currentText == null) {
            return Center(
                child: Text(
              "Arquivo Pessoa (Bonito)",
              style: bonitoTextTheme.headline2,
            ));
          } else {
            return FutureBuilder(
                future: widget.service.fetchText(currentText),
                builder: (ctx, snapshot) {
                  if (snapshot.hasError) return Text("Error ${snapshot.error}");

                  if (!snapshot.hasData) return CircularProgressIndicator();

                  final fetchedText = snapshot.data as PessoaText;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Center(
                              child: Text(currentCategory?.title ?? 'Índice',
                                  style: bonitoTextTheme.subtitle2)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 16.0),
                          child: Text(fetchedText.title,
                              style: bonitoTextTheme.subtitle1),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            fetchedText.content ?? 'NO TEXT',
                            textAlign: TextAlign.left,
                            style: bonitoTextTheme.bodyText2!
                                .copyWith(height: 1.4),
                          ),
                        )
                      ],
                    ),
                  );
                });
          }
        }(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
