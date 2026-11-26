import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

class BackLink extends StatelessWidget {
  final String label;
  const BackLink(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(FirebaseAuth.instance.currentUser == null ? '/login' : '/home');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text('‹ ${tr(label)}',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: context.textMuted)),
      ),
    );
  }
}