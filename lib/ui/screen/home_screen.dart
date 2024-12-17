import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/model/pessoa_text.dart';
import 'package:pessoa_pensadora/model/saved_text.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/widget/navigation_widget.dart';
import 'package:pessoa_pensadora/ui/widget/no_text_reader.dart';
import 'package:pessoa_pensadora/ui/widget/save_text_button.dart';
import 'package:pessoa_pensadora/ui/widget/share_text_button.dart';
import 'package:pessoa_pensadora/ui/widget/text_reader.dart';
import 'package:pessoa_pensadora/ui/widget/text_selection_drawer.dart';
import 'package:pessoa_pensadora/util/generic_extensions.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

import '../../repository/history_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController readerScrollController =
      ScrollController(keepScrollOffset: false);
  final ScrollController drawerScrollController = ScrollController();
  final StreamController<PessoaText> _streamController =
      StreamController.broadcast();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool isFullReading = false;

  _HomeScreenState() : super();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState?.openDrawer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStoreService storeService = Get.find();

    return StreamBuilder<PessoaText>(
        stream: _streamController.stream,
        builder: (ctx, snapshot) {
          final text = snapshot.data;

          if (text != null) Get.find<HistoryRepository>().saveVisit(text.id);

          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              actions: (text == null)
                  ? []
                  : [
                      SaveTextButton(text: SavedText.fromText(text)),
                      ShareTextButton(
                        text: text.content,
                        author: text.author,
                      )
                    ],
            ),
            drawer: TextSelectionDrawer(
              mainIndex: storeService.mainIndex,
              fullIndex: storeService.fullIndex,
              selectionSink: _streamController.sink,
              scrollController: drawerScrollController,
              selectedText: text,
              scaffoldKey: _scaffoldKey,
              isFullReading: isFullReading,
              onFullReadingChange: (newValue) => setState(() {
                isFullReading = newValue;
              }),
            ),
            body: HomeScreenBody(
                text: text,
                streamController: _streamController,
                scrollController: readerScrollController),
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
          content: currentText.content,
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
