import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'play_store_banner_stub.dart'
    if (dart.library.js_interop) 'play_store_banner_web.dart';

const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=me.l3n.pessoapensadora.pessoa_pensadora&utm_source=web-version';

class PlayStoreBanner extends StatefulWidget {
  const PlayStoreBanner({super.key});

  @override
  State<PlayStoreBanner> createState() => _PlayStoreBannerState();
}

class _PlayStoreBannerState extends State<PlayStoreBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !isAndroidBrowser() || _dismissed) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: BonitoTheme.bgElevated,
        border: Border(bottom: BorderSide(color: BonitoTheme.borderCol)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(
              semanticLabel: 'Android',
              Icons.android,
              size: 18,
              color: BonitoTheme.greenTone),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Disponível na Play Store!'
              ' Instala a app para uma melhor experiência.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: BonitoTheme.textDim,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(_playStoreUrl);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: BonitoTheme.bgHover,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: BonitoTheme.borderMid),
              ),
              child: Text(
                'Instalar',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: BonitoTheme.gold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _dismissed = true),
            child:
                const Icon(Icons.close, size: 16, color: BonitoTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
