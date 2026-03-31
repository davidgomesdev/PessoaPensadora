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

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: BonitoTheme.borderCol, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: BonitoTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final allTextIds = _getAllTextIds(category);
                    final totalCount = allTextIds.length;
                    final readCount =
                        allTextIds.where((id) => readCtrl.isRead(id)).length;

                    return Text(
                      '$readCount/$totalCount lidos',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: BonitoTheme.textMuted,
                      ),
                    );
                  }),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: BonitoTheme.bgSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BonitoTheme.borderMid),
              ),
              child: Text(
                '${_getAllTextIds(category).length} textos',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: BonitoTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: BonitoTheme.textMuted, size: 18),
          ],
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

