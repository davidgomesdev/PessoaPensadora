import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/model/pessoa_category.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/widget/text_row_widget.dart';

class TextsListScreen extends StatelessWidget {
  static const routeName = '/textsList';

  const TextsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PessoaCategory category = Get.arguments as PessoaCategory;
    final filterQuery = ''.obs;

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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              height: 36,
              child: TextField(
                style: GoogleFonts.inter(
                    fontSize: 13, color: BonitoTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Filtrar textos…',
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
              final texts = category.texts
                  .where((t) => q.isEmpty || t.title.toLowerCase().contains(q))
                  .toList();

              return ListView.builder(
                itemCount: texts.length,
                itemBuilder: (ctx, i) => TextRowWidget(
                  text: texts[i],
                  index: i,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
