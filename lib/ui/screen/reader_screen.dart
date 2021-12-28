import 'package:flutter/material.dart';
import 'package:pessoa_bonito/service/arquivo_pessoa_service.dart';
import 'package:pessoa_bonito/ui/widget/no_text_reader.dart';
import 'package:pessoa_bonito/ui/widget/text_reader.dart';
import 'package:pessoa_bonito/ui/widget/text_selection_drawer.dart';

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
        setCurrentTextCallback: setCurrentText,
      ),
      body: Container(
        child: () {
          final currentText = this.currentText;

          return currentText == null
              ? NoTextReader()
              : TextReader(
                  service: widget.service,
                  currentCategory: currentCategory,
                  currentText: currentText,
                );
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
