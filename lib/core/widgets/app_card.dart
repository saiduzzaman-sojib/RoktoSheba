import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final bool dark;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const AppCard({
    super.key,
    required this.child,
    this.dark = false,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final Gradient gradient = dark
        ? (isDark ? AppColors.dHero : AppColors.darkGradient)
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [context.surface, context.surfaceAlt],
          );

    final Color border = dark
        ? Colors.white.withValues(alpha: .10)
        : isDark
            ? Colors.white.withValues(alpha: .06)
            : Colors.white;

    final Color shadow = isDark
        ? Colors.black.withValues(alpha: .5)
        : dark
            ? AppColors.ink.withValues(alpha: .4)
            : AppColors.red.withValues(alpha: .18);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 28,
              offset: const Offset(0, 12),
              spreadRadius: -12,
            ),
          ],
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: dark ? Colors.white : context.textMain),
          child: child,
        ),
      ),
    );
  }
}