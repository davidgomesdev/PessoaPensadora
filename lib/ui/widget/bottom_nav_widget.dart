import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pessoa_pensadora/ui/bonito_theme.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        (GetPlatform.isWeb && GetPlatform.isMobile) ? 16.0 : 0.0;

    return Container(
      height: 58 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: BonitoTheme.bgSecondary,
        border: Border(top: BorderSide(color: BonitoTheme.borderCol)),
      ),
      child: Row(
        children: [
          _NavBtn(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore,
              label: 'Explorar',
              index: 0,
              currentIndex: currentIndex,
              onTap: onTap),
          _NavBtn(
              icon: Icons.bookmark_outline,
              activeIcon: Icons.bookmark,
              label: 'Guardados',
              index: 1,
              currentIndex: currentIndex,
              onTap: onTap),
          _NavBtn(
              icon: Icons.history_outlined,
              activeIcon: Icons.history,
              label: 'Histórico',
              index: 2,
              currentIndex: currentIndex,
              onTap: onTap),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavBtn({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 20,
                  color: isActive ? BonitoTheme.gold : BonitoTheme.textMuted,
                ),
                const SizedBox(height: 3),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    letterSpacing: 1.1,
                    color: isActive ? BonitoTheme.gold : BonitoTheme.textMuted,
                  ),
                ),
              ],
            ),
            if (isActive)
              Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: Container(height: 1, color: BonitoTheme.gold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
