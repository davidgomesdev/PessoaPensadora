import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

import '../../model/pessoa_text.dart';
import '../../repository/read_store.dart';
import '../../util/action_feedback.dart';
import '../bonito_theme.dart';

class DrawerListView extends StatelessWidget {
  final Sink<PessoaText> selectionSink;
  final Iterable<ListTile> subcategories;
  final List<PessoaText> texts;
  final int? selectedTextId;
  final ScrollController scrollController;
  final Callback onReadChange;

  const DrawerListView(
      {super.key,
      required this.selectionSink,
      required this.scrollController,
      required this.subcategories,
      required this.texts,
      required this.selectedTextId,
      required this.onReadChange});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey("drawer-list-view"),
      controller: scrollController,
      children: [
        ...ListTile.divideTiles(
          color: Colors.white,
          tiles: [
            ...subcategories,
            ...texts.map((text) => DrawerListTile(
                selectionSink, text, selectedTextId, onReadChange: onReadChange,))
          ],
        ),
      ],
    );
  }
}

class DrawerListTile extends StatefulWidget {
  final Sink<PessoaText> selectionSink;
  final PessoaText text;
  final int? selectedTextId;
  final Callback onReadChange;

  const DrawerListTile(
    this.selectionSink,
    this.text,
    this.selectedTextId, {
      required this.onReadChange,
    super.key,
  });

  @override
  State<DrawerListTile> createState() => _DrawerListTileState();
}

class _DrawerListTileState extends State<DrawerListTile> {
  @override
  Widget build(BuildContext context) {
    final isTextRead = Get.find<ReadRepository>().isTextRead(widget.text.id);

    return ListTile(
      horizontalTitleGap: 8.0,
      minLeadingWidth: 0.0,
      leading: const Icon(Icons.text_snippet_rounded),
      title: Text(widget.text.title, style: bonitoTextTheme.headlineMedium),
      textColor: (isTextRead) ? Colors.white60 : Colors.white,
      selected: widget.text.id == widget.selectedTextId,
      selectedColor: (isTextRead) ? Colors.white60 : Colors.white,
      selectedTileColor: Colors.white10,
      onTap: () {
        widget.selectionSink.add(widget.text);
        Navigator.pop(context);
      },
      onLongPress: () {
          ReadRepository readRepository = Get.find();

          readRepository.toggleRead(widget.text.id);
          ActionFeedback.lightHaptic();
          widget.onReadChange();
      },
    );
  }
}
