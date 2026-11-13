import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

class RoktoshebaApp extends StatelessWidget {
  const RoktoshebaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roktosheba',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: child,
      ),
      // Router (go_router) is wired up in Step 3
      home: const Scaffold(
        body: Center(
          child: Text('Roktosheba',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}