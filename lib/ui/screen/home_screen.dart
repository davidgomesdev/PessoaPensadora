import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/model/pessoa_text.dart';
import 'package:pessoa_pensadora/model/saved_text.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/widget/button/arquivo_pessoa_button.dart';
import 'package:pessoa_pensadora/ui/widget/navigation_widget.dart';
import 'package:pessoa_pensadora/ui/widget/reader/no_text_reader.dart';
import 'package:pessoa_pensadora/ui/widget/button/save_text_button.dart';
import 'package:pessoa_pensadora/ui/widget/button/share_text_button.dart';
import 'package:pessoa_pensadora/ui/widget/reader/text_reader.dart';
import 'package:pessoa_pensadora/ui/widget/text_selection_drawer.dart';
import 'package:pessoa_pensadora/util/generic_extensions.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

import '../../repository/history_store.dart';
import '../../repository/reader_preference_store.dart';

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
  final StreamController<PessoaText> _currentTextStreamController =
      StreamController.broadcast();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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
    final ReaderPreferenceStore readerPreferenceStore = Get.find();

    return StreamBuilder<PessoaText>(
        stream: _currentTextStreamController.stream,
        builder: (ctx, snapshot) {
          final text = snapshot.data;

          if (text != null) Get.find<HistoryRepository>().saveVisit(text.id);

          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              leading: Builder(builder: (context) {
                return GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        Icon(Icons.menu),
                        SizedBox(width: 8),
                        Text(
                          "Índice",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              leadingWidth: 200,
              actions: (text == null)
                  ? []
                  : [
                      SaveTextButton(text: SavedText.fromText(text)),
                      ArquivoPessoaButton(textId: text.id),
                      ShareTextButton(
                        text: text.content,
                        author: text.author,
                      )
                    ],
            ),
            drawer: TextSelectionDrawer(
              mainIndex: storeService.mainIndex,
              fullIndex: storeService.fullIndex,
              selectionSink: _currentTextStreamController.sink,
              scrollController: drawerScrollController,
              selectedText: text,
              scaffoldKey: _scaffoldKey,
              readerPreferenceStore: readerPreferenceStore,
              onFullReadingChange: (newValue) => setState(() {
                readerPreferenceStore.swapReadingMode();
              }),
            ),
            body: HomeScreenBody(
                text: text,
                streamController: _currentTextStreamController,
                scrollController: readerScrollController),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();

    _currentTextStreamController.close();
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

    return StreamBuilder(
        stream: streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            _scrollToTop();
          }

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
        });
  }

  void _handleNavigation(PessoaText? newText) {
    if (newText == null) {
      log.i("Swipe no-op");
      return;
    }

    log.i("Swipe to ${newText.title}");
    streamController.add(newText);

    _scrollToTop();
  }

  void _scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0.0);
    }
  }
}
