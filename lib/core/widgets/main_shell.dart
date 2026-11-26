import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  static const _tabKeys = ['Home', 'Nearby', 'Request', 'Camps', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: 14,
            right: 14,
            bottom: 12 + bottom,
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [Color(0xFF26262C), Color(0xFF1B1B20)]
                      : const [Color(0xFF352B3C), AppColors.ink],
                ),
                borderRadius: BorderRadius.circular(26),
                border: isDark
                    ? Border.all(color: Colors.white.withValues(alpha: .08))
                    : null,
                boxShadow: [
                  BoxShadow(
                      color: (isDark ? Colors.black : AppColors.ink)
                          .withValues(alpha: .65),
                      blurRadius: 40,
                      offset: const Offset(0, 22),
                      spreadRadius: -10),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < _tabKeys.length; i++)
                    _NavItem(
                      label: tr(_tabKeys[i]),
                      on: navigationShell.currentIndex == i,
                      onTap: () => navigationShell.goBranch(i,
                          initialLocation: i == navigationShell.currentIndex),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _NavItem({required this.label, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                    color: on ? Colors.white : const Color(0xFFA8A3AD))),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? AppColors.redLight : Colors.transparent,
                boxShadow: on
                    ? [const BoxShadow(color: AppColors.redLight, blurRadius: 8)]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}