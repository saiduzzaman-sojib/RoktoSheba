import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BloodDrop extends StatefulWidget {
  final double size;
  final bool white;
  final bool pulse;
  const BloodDrop({super.key, this.size = 36, this.white = false, this.pulse = false});

  @override
  State<BloodDrop> createState() => _BloodDropState();
}

class _BloodDropState extends State<BloodDrop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Radius.circular(widget.size / 2);
    final drop = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.white ? Colors.white : null,
        gradient: widget.white ? null : AppColors.redGradient,
        borderRadius: BorderRadius.only(
            topLeft: r, topRight: Radius.zero, bottomLeft: r, bottomRight: r),
        boxShadow: [
          BoxShadow(
            color: widget.white
                ? Colors.white.withValues(alpha: .5)
                : AppColors.red.withValues(alpha: .6),
            blurRadius: widget.white ? 60 : 18,
            offset: widget.white ? Offset.zero : const Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
    );
    final rotated = Transform.rotate(angle: -math.pi / 4, child: drop);
    if (!widget.pulse) return rotated;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) =>
          Transform.scale(scale: 1 + .1 * _c.value, child: child),
      child: rotated,
    );
  }
}