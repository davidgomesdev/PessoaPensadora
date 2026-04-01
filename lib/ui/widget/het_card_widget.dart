import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/model/pessoa_category.dart';
import 'package:pessoa_pensadora/service/read_controller.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class HetCardWidget extends StatelessWidget {
  final PessoaCategory category;
  final String subtitle;
  final VoidCallback onTap;

  const HetCardWidget({
    super.key,
    required this.category,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final readCtrl = Get.find<ReadController>();
    final allTextIds = _getAllTextIds(category);
    final totalCount = allTextIds.length;
    final collCount = category.subcategories.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: BonitoTheme.bgSecondary,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: BonitoTheme.borderCol),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // card-name
              Text(
                category.title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: BonitoTheme.textPrimary,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(height: 3),
              // card-sub
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: BonitoTheme.textDim,
                ),
              ),
              const SizedBox(height: 13),
              // card-stats: plain text with goldDim numbers
              Row(
                children: [
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: '$collCount',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: BonitoTheme.goldDim,
                        ),
                      ),
                      TextSpan(
                        text: ' coleções',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: BonitoTheme.textMuted,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 14),
                  Obx(() {
                    final readCount = allTextIds
                        .where((id) => readCtrl.isRead(id))
                        .length;
                    return Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: '$readCount/$totalCount',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: BonitoTheme.goldDim,
                          ),
                        ),
                        TextSpan(
                          text: ' lidos',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: BonitoTheme.textMuted,
                          ),
                        ),
                      ]),
                    );
                  }),
                ],
              ),
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
