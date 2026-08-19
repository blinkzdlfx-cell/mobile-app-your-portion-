// Apple-style skeleton shimmer system.
//
// Usage: wrap one or more [SkeletonBox] / [SkeletonCircle] / [SkeletonLines]
// in a single [SkeletonShimmer] so a whole section shares one animation
// controller, then swap the skeleton in while real data loads.
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Animated shimmer sweep that tints everything below it (srcATop).
/// All boxes are painted with the current theme's surface colors, so the
/// same skeleton works in light and dark mode.
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppTheme.surfaceContainerHigh;
    final highlight = Color.lerp(
      base,
      AppTheme.isDark ? const Color(0xFF4a504d) : const Color(0xFFffffff),
      AppTheme.isDark ? 0.35 : 0.6,
    )!;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final sweep = (2 * _controller.value - 1) * bounds.width * 1.5;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.3, 0.5, 0.7],
              transform: _SweepGradientTransform(sweep),
            ).createShader(bounds);
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _SweepGradientTransform extends GradientTransform {
  const _SweepGradientTransform(this.dx);

  final double dx;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0, 0);
  }
}

/// Solid rounded rectangle placeholder (painted by the shimmer above it).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Circular placeholder (avatars, icons).
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Text-lookalike placeholder: [lines] rows, each [lineHeight] tall, the last
/// one shorter — reads like Apple's text placeholders.
class SkeletonLines extends StatelessWidget {
  const SkeletonLines({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.gap = 10,
    this.radius = 6,
  });

  final int lines;
  final double lineHeight;
  final double gap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (i) {
        final isLast = i == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : gap),
          child: FractionallySizedBox(
            widthFactor: isLast ? 0.55 : 1.0,
            child: SkeletonBox(height: lineHeight, radius: radius),
          ),
        );
      }),
    );
  }
}

/// Convenience: whole skeleton section already shimmering.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(child: child);
  }
}