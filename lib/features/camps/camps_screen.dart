import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/distance.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/blood_chip.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../admin/admin_provider.dart';
import '../admin/seed_data.dart';
import '../donors/providers/donor_provider.dart';
import 'camp.dart';
import 'camp_provider.dart';

class CampsScreen extends ConsumerStatefulWidget {
  const CampsScreen({super.key});
  @override
  ConsumerState<CampsScreen> createState() => _CampsScreenState();
}

class _CampsScreenState extends ConsumerState<CampsScreen> {
  String _mode = 'Upcoming';
  bool _seeding = false;

  Future<void> _seed() async {
    final m = ScaffoldMessenger.of(context);
    setState(() => _seeding = true);
    try {
      await seedSampleData();
      m.showSnackBar(SnackBar(content: Text(tr('Sample camps and articles added.'))));
    } catch (_) {
      m.showSnackBar(const SnackBar(
          content: Text('Failed. Is your account an admin in Firestore (users/uid/role)?')));
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(campsProvider);
    final isAdmin = ref.watch(isAdminProvider).value ?? false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming =
        (async.value ?? const <Camp>[]).where((c) => !c.date.isBefore(today)).toList();

    final body = <Widget>[];
    if (async.isLoading && !async.hasValue) {
      body.add(const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator(color: AppColors.red))));
    } else if (async.hasError && !async.hasValue) {
      body.add(FieldLabel(tr('Could not load camps. Check your internet.')));
    } else if (_mode == 'Upcoming') {
      if (upcoming.isEmpty) {
        body.add(FieldLabel(tr('No upcoming camps yet. Check back soon.')));
      }
      for (final c in upcoming) {
        body.add(_CampTile(c: c));
      }
    } else {
      final loc = ref.watch(myLocationProvider);
      final point = loc.value?.point;
      if (loc.isLoading) {
        body.add(const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator(color: AppColors.red))));
      } else if (point == null) {
        body.add(AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('Location needed'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            FieldLabel(tr('Allow location to sort camps by distance.')),
            const SizedBox(height: 14),
            AppButton(
                label: tr('Try again'),
                onPressed: () => ref.invalidate(myLocationProvider)),
          ]),
        ));
      } else {
        final items = <(Camp, double?)>[
          for (final c in upcoming)
            (
              c,
              c.location == null
                  ? null
                  : distanceKm(point.latitude, point.longitude, c.location!.latitude,
                      c.location!.longitude)
            ),
        ];
        items.sort((a, b) {
          if (a.$2 == null && b.$2 == null) return 0;
          if (a.$2 == null) return 1;
          if (b.$2 == null) return -1;
          return a.$2!.compareTo(b.$2!);
        });
        if (items.isEmpty) body.add(FieldLabel(tr('No upcoming camps yet.')));
        for (final i in items) {
          body.add(_CampTile(c: i.$1, km: i.$2));
        }
      }
    }

    return AppPage(children: [
      Text(tr('Donation camps'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      Row(children: [
        for (final x in ['Upcoming', 'Near me']) ...[
          BloodChip(
              label: tr(x),
              selected: _mode == x,
              onTap: () => setState(() => _mode = x)),
          const SizedBox(width: 8),
        ],
      ]),
      ...body,
      AppCard(
        onTap: () => context.push('/blog'),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Health tips & stories'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              FieldLabel(tr('Donation tips, myths and donor stories')),
            ]),
          ),
          Text(tr('Read'),
              style: TextStyle(color: context.accent, fontWeight: FontWeight.w800)),
        ]),
      ),
      if (isAdmin)
        AppButton(
            label: 'Add sample camps & articles (admin)',
            loading: _seeding,
            onPressed: _seed),
    ]);
  }
}

class _CampTile extends ConsumerWidget {
  final Camp c;
  final double? km;
  const _CampTile({required this.c, this.km});

  Future<void> _remind(BuildContext context, WidgetRef ref) async {
    final m = ScaffoldMessenger.of(context);
    final added = await ref.read(campRemindersProvider.notifier).toggle(c.id);
    m.showSnackBar(SnackBar(
        content: Text(added
            ? tr('Reminder set. We will remind you on Home when it is close.')
            : tr('Reminder removed'))));
  }

  Future<void> _directions() async {
    final l = c.location;
    if (l == null) return;
    await launchUrl(
      Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${l.latitude},${l.longitude}'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminded = ref.watch(campRemindersProvider).contains(c.id);
    final sub = [
      c.place,
      if (c.organizer.isNotEmpty) c.organizer,
      if (km != null) trp('{n} km', {'n': km!.toStringAsFixed(1)}),
    ].join(' · ');

    return AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 60,
          height: 68,
          decoration: BoxDecoration(
              gradient: AppColors.redGradient, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(bnNum(c.date.day.toString().padLeft(2, '0')),
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            Text(monthShort(c.date.month),
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            FieldLabel(sub),
            if (c.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: FieldLabel(c.description),
              ),
            const SizedBox(height: 8),
            Row(children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _remind(context, ref),
                child: Text(reminded ? tr('Reminder set ✓') : tr('Set reminder'),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: reminded ? AppColors.green : context.accent)),
              ),
              if (c.location != null) ...[
                const SizedBox(width: 18),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _directions,
                  child: Text(tr('Directions'),
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800, color: context.accent)),
                ),
              ],
            ]),
          ]),
        ),
      ]),
    );
  }
}