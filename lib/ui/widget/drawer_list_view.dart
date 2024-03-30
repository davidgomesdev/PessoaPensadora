import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/pessoa_text.dart';
import '../../repository/read_store.dart';
import '../../util/action_feedback.dart';
import '../bonito_theme.dart';

class DrawerListView extends StatefulWidget {
  final Sink<PessoaText> selectionSink;
  final Iterable<ListTile> subcategories;
  final List<PessoaText> texts;
  final int? selectedTextId;
  final ScrollController scrollController;

  const DrawerListView(
      {super.key,
      required this.selectionSink,
      required this.scrollController,
      required this.subcategories,
      required this.texts,
      required this.selectedTextId});

  @override
  State<DrawerListView> createState() => _DrawerListViewState();
}

class _DrawerListViewState extends State<DrawerListView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey("drawer-list-view"),
      controller: widget.scrollController,
      children: [
        ...ListTile.divideTiles(
          color: Colors.white,
          tiles: [
            ...widget.subcategories,
            ...widget.texts.map((text) => DrawerListTile(
                widget.selectionSink, text, widget.selectedTextId))
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

  const DrawerListTile(
    this.selectionSink,
    this.text,
    this.selectedTextId, {
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
        setState(() {
          ReadRepository readRepository = Get.find();

          readRepository.toggleRead(widget.text.id);
          ActionFeedback.lightHaptic();
        });
      },
    );
  }
}
