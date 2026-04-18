import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/repository/reader_preference_store.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/screen/history_screen.dart';
import 'package:pessoa_pensadora/ui/screen/saved_texts_screen.dart';
import 'package:pessoa_pensadora/ui/widget/bottom_nav_widget.dart';
import 'package:pessoa_pensadora/ui/widget/button/bug_report_button.dart';
import 'package:pessoa_pensadora/ui/widget/button/buy_me_a_tea_button.dart';
import 'package:pessoa_pensadora/ui/widget/category_card_widget.dart';
import 'category_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

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
            scrolledUnderElevation: 0,
            titleSpacing: 14,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: BonitoTheme.borderCol, height: 1.0),
            ),
            title: Row(
              children: [
                Logo(),
                const SizedBox(width: 10),
                Container(width: 1, height: 28, color: BonitoTheme.borderMid),
                const SizedBox(width: 10),
                Expanded(
                    child:
                        GlobalSearchField(searchController: searchController)),
                // The Bug report button isn't working on web, need to change the dependency
                if (!GetPlatform.isWeb) const SizedBox(width: 10),
                if (!GetPlatform.isWeb) const BugReportButton(),
                const SizedBox(width: 10),
                const BuyMeATeaButton()
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

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
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
          style: GoogleFonts.lora(
            fontSize: 11,
            letterSpacing: 1.6,
            color: BonitoTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

class GlobalSearchField extends StatelessWidget {
  const GlobalSearchField({
    super.key,
    required this.searchController,
  });

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: BonitoTheme.borderCol),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: BonitoTheme.borderCol),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: BonitoTheme.goldDim),
          ),
          suffixIcon:
              const Icon(Icons.search, size: 16, color: BonitoTheme.textMuted),
        ),
        onSubmitted: (q) {
          if (q.trim().isNotEmpty) {
            searchController.clear();
            Get.toNamed(SearchScreen.routeName, parameters: {'q': q.trim()});
          }
        },
      ),
    );
  }
}

class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  // TODO: extract to assets or something, to avoid hardcoding these in the UI code
  static const Map<int, String> _subtitles = {
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

  @override
  Widget build(BuildContext context) {
    final TextStoreService store = Get.find();
    final ReaderPreferenceStore prefStore = Get.find();
    final showFullIndex = prefStore.isFullReadingMode;
    final cats = showFullIndex
        ? store.fullIndex.subcategories
        : store.mainIndex.subcategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: BonitoTheme.borderCol)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _IndexToggle(
                showFull: showFullIndex,
                onChanged: (v) => setState(() {
                  prefStore.swapReadingMode();
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
            children: cats
                .map((cat) => CategoryCardWidget(
                      category: cat,
                      subtitle: _subtitles[cat.id] ?? '',
                      onTap: () =>
                          Get.toNamed(CategoryScreen.routeName, arguments: cat),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _IndexToggle extends StatelessWidget {
  final bool showFull;
  final ValueChanged<bool> onChanged;

  const _IndexToggle({required this.showFull, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: BonitoTheme.bgElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: BonitoTheme.borderMid),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleSegment(
            label: 'Principal',
            active: !showFull,
            isFirst: true,
            onTap: () => onChanged(false),
          ),
          Container(width: 1, color: BonitoTheme.borderMid),
          _ToggleSegment(
            label: 'Completo',
            active: showFull,
            isFirst: false,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  final String label;
  final bool active;
  final bool isFirst;
  final VoidCallback onTap;

  const _ToggleSegment({
    required this.label,
    required this.active,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active ? BonitoTheme.bgHover : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(3) : Radius.zero,
            right: isFirst ? Radius.zero : const Radius.circular(3),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 0.4,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active ? BonitoTheme.textPrimary : BonitoTheme.textMuted,
          ),
        ),
      ),
    );
  }
}
