import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/dto/box/box_person_text.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class ReaderNavWidget extends StatelessWidget {
  final List<BoxPessoaText> siblings;
  final int currentIdx;
  final BoxPessoaText? prev;
  final BoxPessoaText? next;
  final Function(BoxPessoaText) onNavigate;

  const ReaderNavWidget({
    super.key,
    required this.siblings,
    required this.currentIdx,
    required this.prev,
    required this.next,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    if (siblings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          flex: 42,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _NavBtn(
              label: '← ${prev?.title ?? "Anterior"}',
              enabled: prev != null,
              onTap: () {
                if (prev != null) onNavigate(prev!);
              },
            ),
          ),
        ),
        Expanded(
          flex: 16,
          child: Center(
            child: Text(
              currentIdx >= 0
                  ? '${currentIdx + 1} / ${siblings.length}'
                  : '',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: BonitoTheme.textMuted,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 42,
          child: Align(
            alignment: Alignment.centerRight,
            child: _NavBtn(
              label: '${next?.title ?? "Seguinte"} →',
              enabled: next != null,
              onTap: () {
                if (next != null) onNavigate(next!);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavBtn({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.25,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 160),
          decoration: BoxDecoration(
            color: BonitoTheme.bgSecondary,
            border: Border.all(color: BonitoTheme.borderCol),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: BonitoTheme.textDim,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}


