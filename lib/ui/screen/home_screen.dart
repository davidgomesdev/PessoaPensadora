import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/service/action_service.dart';
import 'package:pessoa_bonito/ui/widget/no_text_reader.dart';
import 'package:pessoa_bonito/ui/widget/text_reader.dart';
import 'package:pessoa_bonito/ui/widget/text_selection_drawer.dart';
import 'package:pessoa_bonito/util/generic_extensions.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

// Avoids accidental swipe when scrolling
const swipeSensitivity = 16;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final StreamController<PessoaText> _streamController =
      StreamController.broadcast();

  _HomeScreenState() : super();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ActionService service = Get.find();
    final PessoaCategory index = Get.find();

    return StreamBuilder<PessoaText>(
        stream: _streamController.stream,
        builder: (ctx, snapshot) {
          final text = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              actions: (text == null)
                  ? []
                  : [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              if (service.isTextSaved(text.id)) {
                                service.deleteText(text.id);
                              } else {
                                service.saveText(text);
                              }
                            });
                          },
                          icon: Icon(service.isTextSaved(text.id)
                              ? Icons.download_done
                              : Icons.download))
                    ],
            ),
            drawer: TextSelectionDrawer(
                index: index,
                selectionSink: _streamController.sink,
                selectedText: text),
            body:
                HomeScreenBody(text: text, streamController: _streamController),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();

    _streamController.close();
  }
}

class HomeScreenBody extends StatelessWidget {
  final PessoaText? text;
  final StreamController<PessoaText> streamController;

  const HomeScreenBody({
    super.key,
    required this.text,
    required this.streamController,
  });

  @override
  Widget build(BuildContext context) {
    final currentText = text;

    return SafeArea(
      child: (currentText == null)
          ? const NoTextReader()
          : TextReaderArea(
              streamController: streamController,
              currentText: currentText,
            ),
    );
  }
}

class TextReaderArea extends StatelessWidget {
  final StreamController<PessoaText> streamController;
  final PessoaText currentText;

  const TextReaderArea({
    super.key,
    required this.streamController,
    required this.currentText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final vel = details.primaryVelocity;

        if (vel == null) return;

        final category = currentText.category!;
        PessoaText? newText;

        if (vel <= -swipeSensitivity) {
          newText = category.texts
              .firstWhereOrNull((text) => text.id > currentText.id);

          log.i("Swiping to next text");
        } else if (vel >= swipeSensitivity) {
          newText = category.texts.reversed
              .firstWhereOrNull((text) => text.id < currentText.id);

          log.i("Swiping to previous text");
        }

        if (newText != null) {
          log.i("Swipe to ${newText.title}");
          streamController.add(newText);
        } else {
          log.i("Swipe no-op");
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: TextReader(
          categoryTitle: currentText.category!.title,
          currentText: currentText,
        ),
      ),
    );
  }
}
