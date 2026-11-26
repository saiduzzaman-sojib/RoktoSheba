import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/requests/providers/request_provider.dart';
import '../constants/firestore_paths.dart';
import '../l10n/l10n.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import 'blood_drop.dart';
import '../../features/admin/admin_provider.dart';

/// Wraps the whole app and slides a banner in when a matching request arrives.
class AlertHost extends ConsumerStatefulWidget {
  final Widget child;
  const AlertHost({super.key, required this.child});
  @override
  ConsumerState<AlertHost> createState() => _AlertHostState();
}

class _AlertHostState extends ConsumerState<AlertHost> {
  final _handled = <String>{};
  String? _uid;
  IncomingRequest? _shown;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _hide() {
    _timer?.cancel();
    if (mounted && _shown != null) setState(() => _shown = null);
  }

  void _show(IncomingRequest i) {
    if (!mounted) return;
    setState(() => _shown = i);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 8), _hide);
  }

  Future<void> _check(List<IncomingRequest> list) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != _uid) {
      _uid = uid;
      _handled.clear();
      _hide();
    }
    if (uid == null) return;
    final fresh = list.where((i) => !_handled.contains(i.request.id)).toList();
    if (fresh.isEmpty) return;
    for (final i in fresh) {
      _handled.add(i.request.id);
    }
    for (final i in fresh) {
      final age = DateTime.now().difference(i.request.createdAt ?? DateTime.now());
      if (age > const Duration(days: 1)) continue;
      try {
        final r = await FirebaseFirestore.instance
            .collection(FS.requests)
            .doc(i.request.id)
            .collection(FS.responses)
            .doc(uid)
            .get();
        if (r.exists) continue; // already answered
      } catch (_) {}
      _show(i);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(eligibilityRulesProvider);
    ref.listen<List<IncomingRequest>>(incomingRequestsProvider, (_, next) {
      scheduleMicrotask(() => _check(next));
    });

    final s = _shown;
    final top = MediaQuery.of(context).padding.top;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedPositioned(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
          top: s == null ? -200 : top + 8,
          left: 12,
          right: 12,
          child: s == null
              ? const SizedBox.shrink()
              : Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {
                      final id = s.request.id;
                      _hide();
                      ref.read(routerProvider).push('/request/$id');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.ink.withValues(alpha: .95),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: .5),
                              blurRadius: 36,
                              offset: const Offset(0, 18),
                              spreadRadius: -10),
                        ],
                      ),
                      child: Row(children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(4, 0, 14, 0),
                          child: BloodDrop(size: 20),
                        ),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    trp('Urgent: {group} blood needed',
                                        {'group': s.request.bloodGroup}),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(
                                    '${s.request.hospital}${s.km == null ? '' : ' · ${trp('{n} km from you', {'n': s.km!.toStringAsFixed(1)})}'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ]),
                        ),
                        Text(tr('now'),
                            style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}