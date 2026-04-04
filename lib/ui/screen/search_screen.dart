import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/service/text_store.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:pessoa_pensadora/ui/routes.dart';
import 'package:pessoa_pensadora/ui/widget/highlight_text_widget.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final query = Get.parameters['q'] ?? '';
    final TextStoreService store = Get.find();

    final results = query.isEmpty
        ? []
        : store.texts.values
            .where((t) =>
                t.title.toLowerCase().contains(query.toLowerCase()) ||
                t.content.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: BonitoTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: BonitoTheme.bgSecondary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Pesquisa',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '${results.length} resultado${results.length == 1 ? '' : 's'} encontrado${results.length == 1 ? '' : 's'}',
              style: GoogleFonts.inter(
                  fontSize: 14, color: BonitoTheme.textDim),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '"$query"',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: BonitoTheme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (ctx, i) {
                final boxText = results[i];
                final snippet = _getSnippet(boxText.content, query);

                return InkWell(
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: BonitoTheme.borderCol, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${boxText.author.toUpperCase()} · ${boxText.category.title}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: BonitoTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        HighlightTextWidget(
                          text: boxText.title,
                          query: query,
                          baseStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: BonitoTheme.textPrimary,
                          ),
                        ),
                        if (snippet.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          HighlightTextWidget(
                            text: snippet,
                            query: query,
                            baseStyle: GoogleFonts.inter(
                              fontSize: 12,
                              color: BonitoTheme.textMuted,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getSnippet(String content, String query) {
    final lower = content.toLowerCase();
    final qLower = query.toLowerCase();
    final idx = lower.indexOf(qLower);
    if (idx == -1) return '';
    final start = (idx - 60).clamp(0, content.length);
    final end = (idx + query.length + 60).clamp(0, content.length);
    String snippet = content.substring(start, end).replaceAll('\n', ' ').trim();
    if (start > 0) snippet = '…$snippet';
    if (end < content.length) snippet = '$snippet…';
    return snippet;
  }
}
