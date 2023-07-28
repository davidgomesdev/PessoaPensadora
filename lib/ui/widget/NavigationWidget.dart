import 'package:flutter/widgets.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

// Avoids accidental swipe when scrolling
const swipeSensitivity = 16;

class NavigationWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const NavigationWidget({
    super.key,
    required this.child,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return GestureDetector(
        child: child,
        onTapUp: (details) {
          final x = details.localPosition.dx;
          final middleX = constraints.maxWidth / 2;

          if (x > middleX) {
            log.i('Tapped to next');
            onNext();
          } else {
            log.i('Tapped to previous');
            onPrevious();
          }
        },
        onHorizontalDragEnd: (details) {
          final vel = details.primaryVelocity;

          if (vel == null) return;

          if (vel <= -swipeSensitivity) {
            log.i("Swiped to next");
            onNext();
          } else if (vel >= swipeSensitivity) {
            log.i("Swiped to previous");
            onPrevious();
          }
        },
      );
    });
  }
}
