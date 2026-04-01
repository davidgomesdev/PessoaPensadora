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
            titleSpacing: 14,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: BonitoTheme.borderCol, height: 1.0),
            ),
            title: Row(
              children: [
                // Logo
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pessoa',
                      style: GoogleFonts.lora(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        color: BonitoTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Pensadora',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        letterSpacing: 1.6,
                        color: BonitoTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Container(width: 1, height: 28, color: BonitoTheme.borderMid),
                const SizedBox(width: 10),
                // Search
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: TextField(
                      controller: searchController,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: BonitoTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Pesquisar textos, títulos…',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12,
                          color: BonitoTheme.textMuted,
                        ),
                        filled: true,
                        fillColor: BonitoTheme.bgElevated,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              const BorderSide(color: BonitoTheme.borderCol),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              const BorderSide(color: BonitoTheme.borderCol),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              const BorderSide(color: BonitoTheme.goldDim),
                        ),
                        suffixIcon: const Icon(Icons.search,
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

    // TODO: extract to assets or something, to avoid hardcoding these in the UI code
    // todo: also make this a map of category id to subtitle and name
    final Map<int, String> subtitles = {
      26: 'Mestre dos Heterónimos',
      23: 'O Engenheiro Sensacionista',
      25: 'Ode ao Classicismo',
      27: 'Ortónimo de Fernando Pessoa',
      33: 'Bernardo Soares',
      24: 'A epopeia da nação',
      67: 'Outros heterónimos',
      139: 'Textos publicados em vida',
      10000: 'Do persa ao português',
    };

    // todo: extract every string in the app to a single file or something, to make it easier to manage and translate later on. maybe even create a simple i18n system for it, if we want to support multiple languages in the future

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // content-header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: BonitoTheme.borderCol)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A Obra de Fernando Pessoa',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: BonitoTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                // todo: consider a different text
                'Cinco hetónimos · Uma vida de máscaras',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: BonitoTheme.textDim,
                ),
              ),
            ],
          ),
        ),
        // content-scroll
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
            children: mainCats
                .map((cat) => HetCardWidget(
                      category: cat,
                      subtitle: subtitles[cat.id] ?? '',
                      onTap: () =>
                          Get.toNamed(Routes.categoryScreen, arguments: cat),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
