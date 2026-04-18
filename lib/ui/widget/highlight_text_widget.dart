import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class HighlightTextWidget extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? baseStyle;
  final int? maxLines;

  const HighlightTextWidget({
    super.key,
    required this.text,
    required this.query,
    this.baseStyle,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final style = baseStyle ??
        GoogleFonts.inter(fontSize: 14, color: BonitoTheme.textDim);

    if (query.isEmpty) {
      return Text(text,
          style: style,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null);
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: style));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: style.copyWith(
          color: BonitoTheme.goldBright,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = idx + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }
}
