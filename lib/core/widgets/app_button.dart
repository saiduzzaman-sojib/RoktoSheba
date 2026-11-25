import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool white;
  final bool loading;
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.white = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: white ? Colors.white : null,
          gradient: white ? null : AppColors.redGradient,
          borderRadius: BorderRadius.circular(18),
          border: isDark && !white
              ? Border.all(color: Colors.white.withValues(alpha: .12))
              : null,
          boxShadow: [
            BoxShadow(
              color: white
                  ? Colors.black26
                  : AppColors.red.withValues(alpha: isDark ? .3 : .6),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: -8,
            ),
          ],
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : Text(label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: white ? AppColors.red : Colors.white)),
      ),
    );
  }
}