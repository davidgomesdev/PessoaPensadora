import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class GroupHeaderWidget extends StatelessWidget {
  final String label;

  const GroupHeaderWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: BonitoTheme.bgSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: BonitoTheme.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

