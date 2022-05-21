import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/service/arquivo_pessoa_service.dart';
import 'package:pessoa_bonito/ui/widget/no_text_reader.dart';
import 'package:pessoa_bonito/ui/widget/text_reader.dart';
import 'package:pessoa_bonito/ui/widget/text_selection_drawer.dart';
import 'package:pessoa_bonito/util/generic_extensions.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

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
  final StreamController<PessoaText> _streamController =
      StreamController.broadcast();

  _ReaderScreenState() : super();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PessoaText>(
        stream: _streamController.stream,
        builder: (ctx, snapshot) {
          final text = snapshot.data;

          return Scaffold(
            appBar: AppBar(),
            drawer: TextSelectionDrawer(
                selectionSink: _streamController.sink,
                service: widget.service,
                selectedText: text),
            body: _buildTextReader(text),
          );
        });
  }

  Widget _buildTextReader(PessoaText? text) {
    if (text == null) return const NoTextReader();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final vel = details.primaryVelocity;

        if (vel == null) return;

        final category = text.category;
        PessoaText? newText;

        // Avoids accidental swipe when scrolling
        var swipeSensitivity = 16;

        if (vel <= -swipeSensitivity) {
          newText =
              category.texts.firstWhereOrNull((text) => text.id > text.id);

          log.i("Swiping to next text");
        } else if (vel >= swipeSensitivity) {
          newText = category.texts.reversed
              .firstWhereOrNull((text) => text.id < text.id);

          log.i("Swiping to previous text");
        }

        if (newText != null) {
          log.i("Swipe to ${newText.title}");
          _streamController.add(newText);
        } else {
          log.i("Swipe no-op");
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: TextReader(
          service: widget.service,
          currentCategory: text.category,
          currentText: text,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _streamController.close();
  }
}
