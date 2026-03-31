import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/model/pessoa_category.dart';
import 'package:pessoa_pensadora/service/read_controller.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class HetCardWidget extends StatelessWidget {
  final PessoaCategory category;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const HetCardWidget({
    super.key,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final readCtrl = Get.find<ReadController>();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: BonitoTheme.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: BonitoTheme.borderMid, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BonitoTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: BonitoTheme.textDim,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: BonitoTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final allTextIds = _getAllTextIds(category);
                final totalCount = allTextIds.length;
                final readCount = allTextIds.where((id) => readCtrl.isRead(id)).length;
                final collCount = category.subcategories.length;

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BonitoTheme.bgSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BonitoTheme.borderMid),
                      ),
                      child: Text(
                        '$collCount colecções',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: BonitoTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BonitoTheme.bgSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BonitoTheme.borderMid),
                      ),
                      child: Text(
                        '$readCount/$totalCount lidos',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: readCount == totalCount && totalCount > 0
                              ? BonitoTheme.greenTone
                              : BonitoTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  List<int> _getAllTextIds(PessoaCategory cat) {
    final ids = cat.texts.map((t) => t.id).toList();
    for (final sub in cat.subcategories) {
      ids.addAll(_getAllTextIds(sub));
    }
    return ids;
  }
}

