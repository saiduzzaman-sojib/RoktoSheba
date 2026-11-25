import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-screen gradient background used by every screen.
class GradientScaffold extends StatelessWidget {
  final Widget child;
  const GradientScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: context.bgGradient),
        child: child,
      ),
    );
  }
}

/// Scrollable page with the standard 22px side padding and space for the nav bar.
class AppPage extends StatelessWidget {
  final List<Widget> children;
  final bool navPadding;
  const AppPage({super.key, required this.children, this.navPadding = true});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        bottom: false,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(22, 16, 22, navPadding ? 130 : 32),
          itemCount: children.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (_, i) => children[i],
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: 13, color: context.textMuted));
}