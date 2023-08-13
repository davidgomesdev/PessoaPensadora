import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/service/save_service.dart';
import 'package:pessoa_bonito/service/text_store_service.dart';
import 'package:pessoa_bonito/ui/widget/navigation_widget.dart';
import 'package:pessoa_bonito/ui/widget/no_text_reader.dart';
import 'package:pessoa_bonito/ui/widget/text_reader.dart';
import 'package:pessoa_bonito/ui/widget/text_selection_drawer.dart';
import 'package:pessoa_bonito/util/generic_extensions.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController scrollController =
      ScrollController(keepScrollOffset: false);
  final StreamController<PessoaText> _streamController =
      StreamController.broadcast();

  _HomeScreenState() : super();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SaveService service = Get.find();
    final TextStoreService storeService = Get.find();

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
                              ? Icons.bookmark_outlined
                              : Icons.bookmark_outline_outlined))
                    ],
            ),
            drawer: TextSelectionDrawer(
                index: storeService.index,
                selectionSink: _streamController.sink,
                selectedText: text),
            body: HomeScreenBody(
                text: text,
                streamController: _streamController,
                scrollController: scrollController),
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
  final ScrollController scrollController;

  const HomeScreenBody(
      {super.key,
      required this.text,
      required this.streamController,
      required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final currentText = text;

    return SafeArea(
      child: (currentText == null)
          ? const NoTextReader()
          : TextReaderArea(
              currentText: currentText,
              scrollController: scrollController,
              streamController: streamController,
            ),
    );
  }
}

class TextReaderArea extends StatelessWidget {
  final PessoaText currentText;
  final StreamController<PessoaText> streamController;
  final ScrollController scrollController;

  const TextReaderArea({
    super.key,
    required this.currentText,
    required this.scrollController,
    required this.streamController,
  });

  @override
  Widget build(BuildContext context) {
    final category = currentText.category!;

    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: NavigationWidget(
        child: TextReader(
          categoryTitle: currentText.category!.title,
          title: currentText.title,
          text: currentText.content,
          author: currentText.author,
          scrollController: scrollController,
        ),
        onNext: () {
          final newText = category.texts.getNext(currentText);

          _handleNavigation(newText);
        },
        onPrevious: () {
          final newText = category.texts.getPrevious(currentText);

          _handleNavigation(newText);
        },
      ),
    );
  }

  void _handleNavigation(PessoaText? newText) {
    if (newText == null) {
      log.i("Swipe no-op");
      return;
    }

    log.i("Swipe to ${newText.title}");
    streamController.add(newText);

    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutQuart,
      );
    }
  }
}
