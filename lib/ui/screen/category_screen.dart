import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/model/pessoa_category.dart';
import 'package:pessoa_pensadora/repository/read_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/widget/subcategory_row_widget.dart';
import 'package:pessoa_pensadora/ui/widget/text_row_widget.dart';
import 'package:pessoa_pensadora/ui/widget/text_selection_drawer.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

class CategoryScreen extends StatelessWidget {
  static const routeName = '/category';

  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PessoaCategory category = Get.arguments as PessoaCategory;
    final readRepository = Get.find<ReadRepository>();
    final filterQuery = ''.obs;
    final filterMode = SearchReadFilter.all.obs;

    return Scaffold(
      backgroundColor: BonitoTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: BonitoTheme.bgSecondary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          category.title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: BonitoTheme.textPrimary,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // filter bar
          FilterBar(filterQuery, filterMode),
          Expanded(
            child: Obx(() {
              final query = filterQuery.value.toLowerCase();
              final mode = filterMode.value;
              final subcategories = category.subcategories
                  .where((c) =>
                      query.isEmpty || c.title.toLowerCase().contains(query))
                  .toList();
              var texts = category.texts
                  .where((t) =>
                      query.isEmpty || t.title.toLowerCase().contains(query))
                  .toList();

              if (mode != SearchReadFilter.all) {
                texts = texts
                    .where((t) =>
                        readRepository.isTextRead(t.id) ==
                        (mode == SearchReadFilter.read))
                    .toList();
              }

              if (subcategories.isEmpty && texts.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhum resultado',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: BonitoTheme.textMuted),
                  ),
                );
              }

              final totalItems = subcategories.length + texts.length;

              return ListView.builder(
                itemCount: totalItems,
                itemBuilder: (ctx, i) {
                  var isSubcategory = i < subcategories.length;
                  if (isSubcategory) {
                    final sub = subcategories[i];
                    return SubcategoryRowWidget(
                      category: sub,
                      onTap: () => Get.toNamed(
                        CategoryScreen.routeName,
                        arguments: sub,
                        preventDuplicates: false,
                      ),
                    );
                  } else {
                    final text = texts[i - subcategories.length];
                    return TextRowWidget(
                      text: text,
                      filteredCategoryTexts: texts,
                      index: i - subcategories.length,
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar(
    this.filterQuery,
    this.filterMode, {
    super.key,
  });

  final RxString filterQuery;
  final Rx<SearchReadFilter> filterMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                style: GoogleFonts.inter(
                    fontSize: 13, color: BonitoTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Filtrar…',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 13, color: BonitoTheme.textMuted),
                  filled: true,
                  fillColor: BonitoTheme.bgElevated,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search,
                      size: 16, color: BonitoTheme.textMuted),
                ),
                onChanged: (v) => filterQuery.value = v,
              ),
            ),
            Obx(() {
              final filter = filterMode.value;
              return IconButton(
                  onPressed: () {
                    var newFilterMode = filter.next();

                    log.i('Changing filter mode to: ${newFilterMode.label}');

                    filterMode.value = newFilterMode;
                  },
                  tooltip: filter.label,
                  icon: Icon(filter.icon));
            })
          ],
        ),
      ),
    );
  }
}
