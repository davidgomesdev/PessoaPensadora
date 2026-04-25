import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bonito_theme.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BonitoTheme.bgDeep,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fernando Pessoa',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
                color: BonitoTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 1,
              color: BonitoTheme.gold,
            ),
            const SizedBox(height: 12),
            Text(
              'obra completa',
              style: GoogleFonts.inter(
                fontSize: 11,
                letterSpacing: 3,
                color: BonitoTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
