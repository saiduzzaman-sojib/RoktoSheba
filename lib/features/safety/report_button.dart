import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/telemetry.dart';

const _reasons = [
  'Fake or spam request',
  'Asking for money',
  'Harassment or abuse',
  'Wrong or misleading information',
  'Something else',
];

/// A small "Report" link. [type] is 'request' or 'donor'.
class ReportButton extends StatelessWidget {
  final String type, targetId, targetUserId;
  const ReportButton({
    super.key,
    required this.type,
    required this.targetId,
    required this.targetUserId,
  });

  Future<void> _open(BuildContext context) async {
    final m = ScaffoldMessenger.of(context);
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Why are you reporting this?'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final r in _reasons)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr(r), style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: Icon(Icons.chevron_right, color: c.textMuted),
                  onTap: () => Navigator.pop(c, r),
                ),
            ],
          ),
        ),
      ),
    );
    if (reason == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc('${uid}_${type}_$targetId')
          .set({
        'reporterId': uid,
        'type': type,
        'targetId': targetId,
        'targetUserId': targetUserId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Telemetry.event('report_submitted', {'type': type});
      m.showSnackBar(
          SnackBar(content: Text(tr('Thank you. Our team will review this report.'))));
    } on FirebaseException catch (e) {
      // A second report on the same target is refused by the rules.
      m.showSnackBar(SnackBar(
          content: Text(e.code == 'permission-denied'
              ? tr('You have already reported this.')
              : tr('Could not send the report. Try again.'))));
    } catch (_) {
      m.showSnackBar(
          SnackBar(content: Text(tr('Could not send the report. Try again.'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Never show "Report" on your own request or profile.
    if (FirebaseAuth.instance.currentUser?.uid == targetUserId) {
      return const SizedBox.shrink();
    }
    return Center(
      child: TextButton.icon(
        onPressed: () => _open(context),
        icon: Icon(Icons.flag_outlined, size: 16, color: context.textMuted),
        label: Text(tr('Report'),
            style: TextStyle(
                color: context.textMuted, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}