import 'package:flutter/material.dart';
import 'package:pessoa_bonito/collection/Stack.dart';
import 'package:pessoa_bonito/model/category_text.dart';

import '../bonito_theme.dart';

class ReaderScreen extends StatefulWidget {
  final PessoaIndex index;

  ReaderScreen({Key? key, required this.index}) : super(key: key);

  @override
  _ReaderScreenState createState() => _ReaderScreenState(index);
}

class _ReaderScreenState extends State<ReaderScreen>
    with SingleTickerProviderStateMixin {
  StackCollection<PessoaCategory> previousCategories;
  PessoaCategory currentCategory;
  PessoaText? currentText;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticIn,
  ));

  _ReaderScreenState(PessoaCategory initialCategory)
      : currentCategory = initialCategory,
        previousCategories = StackCollection(),
        // // TODO: this is only when debugging
        currentText = initialCategory.subcategories![0].texts[0],
        super();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final subCategories = currentCategory.subcategories?.map((cat) => ListTile(
              horizontalTitleGap: 8.0,
              minLeadingWidth: 0.0,
              leading: Icon(Icons.subdirectory_arrow_right_rounded),
              title: Text(cat.title, style: bonitoTextTheme.headline4),
              onTap: () {
                setState(() {
                  previousCategories.push(currentCategory);
                  currentCategory = cat;

                  _controller.animateTo(0,
                      duration: Duration(milliseconds: 1500),
                      curve: Curves.easeIn);
                });
              },
            )) ??
        [];
    final texts = currentCategory.texts.map((text) => ListTile(
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

    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
          child: SafeArea(
        child: SlideTransition(
          position: _offsetAnimation,
          child: ListView(
            padding: EdgeInsets.only(top: 24.0),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentCategory.title,
                  style: bonitoTextTheme.headline3,
                ),
              ),
              ...ListTile.divideTiles(
                color: Colors.white70,
                tiles: [
                  ...texts,
                  ...subCategories,
                  if (previousCategories.isNotEmpty)
                    ListTile(
                        horizontalTitleGap: 8.0,
                        minLeadingWidth: 0.0,
                        leading: Icon(Icons.arrow_back_rounded),
                        title: Text("Back", style: bonitoTextTheme.headline4),
                        onTap: () {
                          setState(() {
                            currentCategory = previousCategories.pop()!;
                          });
                        }),
                ],
              ),
            ],
          ),
        ),
      )),
      body: Container(
        child: () {
          if ((currentText == null)) {
            return Center(
                child: Text(
              "Arquivo Pessoa (Bonito)",
              style: bonitoTextTheme.headline2,
            ));
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Center(
                      child: Text(currentCategory.title,
                          style: bonitoTextTheme.subtitle2)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  child: Text(currentText!.title,
                      style: bonitoTextTheme.subtitle1),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentText!.content,
                    textAlign: TextAlign.left,
                    style: bonitoTextTheme.bodyText2!.copyWith(height: 1.4),
                  ),
                )
              ],
            );
          }
        }(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
