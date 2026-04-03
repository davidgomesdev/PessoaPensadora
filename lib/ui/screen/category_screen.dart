import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/model/pessoa_category.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/routes.dart';
import 'package:pessoa_pensadora/ui/widget/coll_item_widget.dart';
import 'package:pessoa_pensadora/ui/widget/text_row_widget.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PessoaCategory category = Get.arguments as PessoaCategory;
    final filterQuery = ''.obs;

    return Scaffold(
      backgroundColor: BonitoTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: BonitoTheme.bgSecondary,
        elevation: 0,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              height: 36,
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
          ),
          Expanded(
            child: Obx(() {
              final q = filterQuery.value.toLowerCase();
              final subs = category.subcategories
                  .where((c) => q.isEmpty || c.title.toLowerCase().contains(q))
                  .toList();
              final texts = category.texts
                  .where((t) => q.isEmpty || t.title.toLowerCase().contains(q))
                  .toList();

              final total = subs.length + texts.length;

              if (total == 0) {
                return Center(
                  child: Text(
                    'Nenhum resultado',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: BonitoTheme.textMuted),
                  ),
                );
              }

              return ListView.builder(
                itemCount: total,
                itemBuilder: (ctx, i) {
                  if (i < subs.length) {
                    final sub = subs[i];
                    return CollItemWidget(
                      category: sub,
                      onTap: () => Get.toNamed(
                        Routes.categoryScreen,
                        arguments: sub,
                        preventDuplicates: false,
                      ),
                    );
                  } else {
                    final text = texts[i - subs.length];
                    return TextRowWidget(text: text, index: i - subs.length);
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
