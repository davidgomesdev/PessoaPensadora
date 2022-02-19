import 'dart:async';

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
  final StreamController<PessoaText> _streamController =
      StreamController.broadcast();

  _ReaderScreenState() : super();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: StreamBuilder<PessoaText>(
          stream: _streamController.stream,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState != ConnectionState.waiting)
              currentCategory = snapshot.data?.category;

            return TextSelectionDrawer(
                selectionSink: _streamController.sink,
                service: widget.service,
                selectedTextCategory: currentCategory);
          }),
      body: StreamBuilder<PessoaText>(
        stream: _streamController.stream,
        builder: (ctx, snapshot) {
          final text = snapshot.data;

          if (text == null) return NoTextReader();

          return TextReader(
            service: widget.service,
            currentCategory: text.category,
            currentText: text,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _streamController.close();
  }
}
