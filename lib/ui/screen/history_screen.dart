import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/repository/history_store.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/routes.dart';
import 'package:pessoa_pensadora/ui/widget/s_item_widget.dart';
import 'package:pessoa_pensadora/ui/screen/splash_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStoreService store = Get.find();
    final HistoryRepository repository = Get.find();

    return Scaffold(
      backgroundColor: BonitoTheme.bgPrimary,
      body: FutureBuilder(
        future: repository.getHistory(),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            snapshot.printError();
            return ErrorWidget(snapshot.error!);
          }

          if (!snapshot.hasData) {
            return const SplashScreen();
          }

          final ids = snapshot.data!.toList();
          final texts = ids
              .map((id) => store.texts[id])
              .whereType<dynamic>()
              .where((t) => t != null)
              .toList();

          return CustomScrollView(
            slivers: [
              if (texts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      // TODO: add something like "Fernando Pessoa tem tantos textos incríveis, vá lê alguns deles!"
                      'Nenhum texto visitado',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: BonitoTheme.textMuted),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final boxText = store.texts[ids[i]];
                      if (boxText == null) return const SizedBox.shrink();
                      return SItemWidget(
                        title: boxText.title,
                        subtitle: boxText.category.title,
                        trailing: '',
                        onTap: () => Get.toNamed(
                          Routes.readTextScreen,
                          arguments: {
                            'id': boxText.id,
                            'categoryTitle': boxText.category.title,
                            'title': boxText.title,
                            'content': boxText.content,
                            'author': boxText.author,
                          },
                        ),
                      );
                    },
                    childCount: ids.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
