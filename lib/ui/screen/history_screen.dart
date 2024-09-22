import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/dto/box/box_person_text.dart';
import 'package:pessoa_pensadora/repository/history_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/screen/splash_screen.dart';

import '../../service/text_store.dart';
import '../routes.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStoreService store = Get.find();
    final HistoryRepository repository = Get.find();

    return FutureBuilder(
        future: repository.getHistory(),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            snapshot.printError();
            return ErrorWidget(snapshot.error!);
          }

          if (!snapshot.hasData) {
            return const SplashScreen();
          }

          final texts = snapshot.data!.map((id) => store.texts[id]).nonNulls;

          return Scaffold(
            body: CustomScrollView(
              scrollBehavior:
                  const ScrollBehavior().copyWith(overscroll: false),
              slivers: [
                SliverAppBar(
                  title: Text("Histórico", style: bonitoTextTheme.displaySmall),
                  pinned: true,
                ),
                SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    sliver: _HistoryTextsSliverList(
                      texts: texts,
                    )),
              ],
            ),
          );
        });
  }
}

class _HistoryTextsSliverList extends StatelessWidget {
  final Iterable<BoxPessoaText> texts;

  const _HistoryTextsSliverList({required this.texts});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemBuilder: (context, index) {
        final text = texts.elementAt(index);

        return _HistoryTextTile(text);
      },
      itemCount: texts.length,
    );
  }
}

class _HistoryTextTile extends StatelessWidget {
  final BoxPessoaText text;

  const _HistoryTextTile(this.text);

  @override
  Widget build(BuildContext context) {
    var textCondensed = text.content.replaceAll("\n\n", "\n").trim();

    return ListTile(
      enableFeedback: true,
      title: Text(
        text.title,
        style:
            bonitoTextTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textCondensed,
              style: bonitoTextTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  text.author,
                  textAlign: TextAlign.right,
                  style: bonitoTextTheme.labelSmall,
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Get.toNamed(Routes.readTextScreen, arguments: {
          "categoryTitle": text.category.title,
          "title": text.title,
          "content": text.content,
          "author": text.author,
        });
      },
    );
  }
}
