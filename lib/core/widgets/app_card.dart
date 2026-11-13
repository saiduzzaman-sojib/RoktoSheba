import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final bool dark;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const AppCard({super.key, required this.child, this.dark = false,
      this.onTap, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          gradient: dark
              ? AppColors.darkGradient
              : const LinearGradient(colors: [Colors.white, Color(0xFFFFF6EF)]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: dark ? Colors.white12 : Colors.white),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? AppColors.ink.withValues(alpha: .4)
                  : AppColors.red.withValues(alpha: .18),
              blurRadius: 28,
              offset: const Offset(0, 12),
              spreadRadius: -12,
            ),
          ],
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: dark ? Colors.white : AppColors.ink),
          child: child,
        ),
      ),
    );
  }
}