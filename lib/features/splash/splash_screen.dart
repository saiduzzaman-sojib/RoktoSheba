import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/blood_drop.dart';
import '../../core/widgets/language_tile.dart';
import '../onboarding/onboarding_screen.dart';

const _onboardedKey = 'onboarded_v1';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _start(BuildContext context) async {
    var seen = false;
    try {
      final p = await SharedPreferences.getInstance();
      seen = p.getBool(_onboardedKey) ?? false;
    } catch (_) {}
    if (!context.mounted) return;

    if (!seen) {
      final done = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      if (done != true || !context.mounted) return;
      try {
        final p = await SharedPreferences.getInstance();
        await p.setBool(_onboardedKey, true);
      } catch (_) {}
      if (!context.mounted) return;
    }
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(.7, -1),
            radius: 1.5,
            colors: [Color(0xFFE8605A), AppColors.red, Color(0xFF4E0F16)],
            stops: [0, .45, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: LanguageChips(),
                ),
                Expanded(
                  child: Center(
                    child: _FadeUp(
                      delay: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const BloodDrop(size: 96, white: true, pulse: true),
                          const SizedBox(height: 56),
                          Text(tr('Roktosheba'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.6)),
                        ],
                      ),
                    ),
                  ),
                ),
                _FadeUp(
                  delay: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('Step forward.\nGive blood, give life.'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.6)),
                      const SizedBox(height: 12),
                      Text(
                          tr('Find eligible donors near you in minutes, and keep your own donation record.'),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 15, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _FadeUp(
                  delay: 450,
                  child: Column(
                    children: [
                      AppButton(
                          label: tr('Get started'),
                          white: true,
                          onPressed: () => _start(context)),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(tr('I already have an account'),
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades in and slides up a little, after an optional delay (ms).
class _FadeUp extends StatefulWidget {
  final Widget child;
  final int delay;
  const _FadeUp({required this.child, required this.delay});

  @override
  State<_FadeUp> createState() => _FadeUpState();
}

class _FadeUpState extends State<_FadeUp> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
  late final _curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
            .animate(_curve),
        child: widget.child,
      ),
    );
  }
}