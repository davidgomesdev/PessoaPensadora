import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/model/pessoa_category.dart';
import 'package:pessoa_pensadora/service/read_controller.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class CollItemWidget extends StatelessWidget {
  final PessoaCategory category;
  final VoidCallback onTap;

  const CollItemWidget({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final readCtrl = Get.find<ReadController>();
    final totalCount = _getAllTextIds(category).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: BonitoTheme.bgSecondary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: BonitoTheme.borderCol),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      category.title,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: BonitoTheme.textPrimary,
                        letterSpacing: 0.15,
                      ),
                    ),
                    const SizedBox(height: 3),

                    Obx(() {
                      final allTextIds = _getAllTextIds(category);
                      final readCount = allTextIds
                          .where((id) => readCtrl.isRead(id))
                          .length;
                      return Text(
                        '$readCount/$totalCount lidos',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: BonitoTheme.textMuted,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BonitoTheme.bgHover,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '$totalCount textos',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: BonitoTheme.textMuted,
                  ),
                ),
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
