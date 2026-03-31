import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class SItemWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing; // null → shows ✕ button (saved), non-null → time string (history)
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const SItemWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: BonitoTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: BonitoTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing != null
                ? Text(
                    trailing!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: BonitoTheme.textMuted,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.close, size: 18, color: BonitoTheme.textMuted),
                    onPressed: onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
          ],
        ),
      ),
    );
  }
}

