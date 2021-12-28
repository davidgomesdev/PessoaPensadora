import 'package:flutter/material.dart';
import 'package:pessoa_bonito/service/arquivo_pessoa_service.dart';
import 'package:pessoa_bonito/ui/widget/text_selection_drawer.dart';

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
  PessoaCategory? currentCategory;
  PessoaText? currentText;

  _ReaderScreenState() : super();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: TextSelectionDrawer(
        service: widget.service,
        initialCategory: currentCategory,
        setCurrentCategoryCallback: setCurrentCategory,
        setCurrentText: setCurrentText,
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
                                  style: bonitoTextTheme.subtitle1)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 16.0),
                          child: Text(fetchedText.title,
                              style: bonitoTextTheme.headline5),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            fetchedText.content ?? 'NO TEXT',
                            textAlign: TextAlign.left,
                            style: bonitoTextTheme.bodyText2!
                                .copyWith(height: 1.4),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              fetchedText.author ?? 'NO AUTHOR',
                              style: bonitoTextTheme.subtitle2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          }
        }(),
      ),
    );
  }

  void setCurrentText(PessoaText text) => setState(() => currentText = text);

  void setCurrentCategory(PessoaCategory? cat) => currentCategory = cat;

  @override
  void dispose() {
    super.dispose();
  }
}
