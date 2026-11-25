import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final base = dark ? const Color(0xFF2A2330) : const Color(0xFFEADFD5);
    final hi = dark ? const Color(0xFF3B3142) : const Color(0xFFFFF6EF);
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (r) => LinearGradient(
          begin: Alignment(-1.5 + 3 * _c.value, -.3),
          end: Alignment(-.5 + 3 * _c.value, .3),
          colors: [base, hi, base],
          stops: const [.1, .5, .9],
        ).createShader(r),
        child: child,
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 8});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(radius)),
      );
}

/// Donor / request card-er moto skeleton.
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 52, height: 52, radius: 26),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 150, height: 15),
                SizedBox(height: 10),
                SkeletonBox(width: 100, height: 12),
              ],
            ),
          ),
          const SkeletonBox(width: 44, height: 32, radius: 12),
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            const CardSkeleton(),
            if (i != count - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}