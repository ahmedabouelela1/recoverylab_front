import 'package:flutter/material.dart';
import 'package:recoverylab_front/configurations/colors.dart';

/// Wraps [child] with an animated gradient overlay to create a shimmer effect.
/// [animation] should be a 0.0 → 1.0 repeating animation (e.g. from an
/// AnimationController with repeat()).
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(value * 2 - 1.0, 0),
                      end: Alignment(value * 2 - 0.5, 0),
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0),
                      ],
                      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A simple bar used inside skeleton layouts. Wrap in [ShimmerBox] for shimmer.
Widget shimmerSkeletonBar({
  required double width,
  required double height,
  double radius = 6,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
