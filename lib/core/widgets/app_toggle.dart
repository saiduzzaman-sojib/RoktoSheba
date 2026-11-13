import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppToggle extends StatelessWidget {
  final bool on;
  final VoidCallback? onTap;
  const AppToggle({super.key, required this.on, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          color: on ? AppColors.red : const Color(0xFF5B5160),
          borderRadius: BorderRadius.circular(15),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}