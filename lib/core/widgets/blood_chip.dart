import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BloodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const BloodChip(
      {super.key, required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.redGradient : null,
          color: selected ? null : (isDark ? context.surfaceAlt : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? Colors.transparent : context.line),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.red.withValues(alpha: isDark ? .35 : .6),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                    spreadRadius: -8,
                  ),
                ]
              : isDark
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: .15),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                        spreadRadius: -8,
                      ),
                    ],
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: selected ? Colors.white : context.textMain)),
      ),
    );
  }
}