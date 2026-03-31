import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/routes.dart';
import 'package:pessoa_pensadora/ui/screen/history_screen.dart';
import 'package:pessoa_pensadora/ui/screen/saved_texts_screen.dart';
import 'package:pessoa_pensadora/ui/widget/bottom_nav_widget.dart';
import 'package:pessoa_pensadora/ui/widget/het_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTab = 0.obs;
    final searchController = TextEditingController();

    return Obx(() => Scaffold(
          backgroundColor: BonitoTheme.bgPrimary,
          appBar: AppBar(
            backgroundColor: BonitoTheme.bgSecondary,
            elevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                Text(
                  'Pessoa',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BonitoTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: TextField(
                      controller: searchController,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: BonitoTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Pesquisar…',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13,
                          color: BonitoTheme.textMuted,
                        ),
                        filled: true,
                        fillColor: BonitoTheme.bgElevated,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search,
                            size: 16, color: BonitoTheme.textMuted),
                      ),
                      onSubmitted: (q) {
                        if (q.trim().isNotEmpty) {
                          searchController.clear();
                          Get.toNamed(Routes.searchScreen,
                              parameters: {'q': q.trim()});
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: BottomNavWidget(
              currentIndex: currentTab.value,
              onTap: (i) => currentTab.value = i,
            ),
          ),
          body: IndexedStack(
            index: currentTab.value,
            children: const [
              BrowseTab(),
              SavedTextsScreen(),
              HistoryScreen(),
            ],
          ),
        ));
  }
}

// ─── Browse Tab ──────────────────────────────────────────────────────────────

class BrowseTab extends StatelessWidget {
  const BrowseTab({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStoreService store = Get.find();
    final mainCats = store.mainIndex.subcategories;

    final Map<int, String> subtitles = {
      26: 'Mestre dos Heterónimos',
      23: 'O Engenheiro Sensacionista',
      25: 'Ode ao Classicismo',
      27: 'Ortónimo de Fernando Pessoa',
      33: 'Bernardo Soares',
      24: 'A epopeia da nação',
      67: 'Outros heterónimos',
      139: 'Textos publicados em vida',
      10000: 'Rubaiyat',
    };
    final Map<int, String> descriptions = {
      26: 'Pensa com sensações',
      23: 'Sente com pensamentos',
      25: 'A regra como beleza',
      27: 'O eu sem heterónimo',
      33: 'O devaneio como método',
      24: 'Portugal como destino',
      67: 'Vozes da sombra',
      139: 'Da vida para a página',
      10000: 'Do persa ao português',
    };

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'A Obra de Fernando Pessoa',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BonitoTheme.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            'Cinco heterónimos · Uma vida de escrita',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: BonitoTheme.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...mainCats.map((cat) => HetCardWidget(
              category: cat,
              subtitle: subtitles[cat.id] ?? '',
              description: descriptions[cat.id] ?? '',
              onTap: () => Get.toNamed(Routes.categoryScreen, arguments: cat),
            )),
      ],
    );
  }
}
