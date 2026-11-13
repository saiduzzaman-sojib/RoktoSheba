import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/blood_drop.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BloodDrop(size: 96, white: true, pulse: true),
                        SizedBox(height: 56),
                        Text('Roktosheba',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.6)),
                      ],
                    ),
                  ),
                ),
                const Text('Step forward.\nGive blood, give life.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.6)),
                const SizedBox(height: 12),
                const Text(
                    'Find eligible donors near you in minutes, and keep your own donation record.',
                    style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
                const SizedBox(height: 24),
                AppButton(
                    label: 'Get started',
                    white: true,
                    onPressed: () => context.go('/register')),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('I already have an account',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
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