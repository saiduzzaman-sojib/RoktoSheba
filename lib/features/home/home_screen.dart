import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_toggle.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/blood_drop.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../auth/providers/auth_provider.dart';
import '../camps/camp_reminder_section.dart';
import '../donors/models/donor.dart';
import '../donors/providers/donor_provider.dart';
import '../requests/presentation/request_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greet() {
    final h = DateTime.now().hour;
    return tr(h < 12
        ? 'Good morning'
        : h < 17
            ? 'Good afternoon'
            : 'Good evening');
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, Donor d) async {
    final m = ScaffoldMessenger.of(context);
    if (d.blocked) {
      m.showSnackBar(SnackBar(
          content: Text(tr('Your account is restricted by an admin.'))));
      return;
    }
    if (!d.available && !d.eligibleNow) {
      m.showSnackBar(SnackBar(
          content: Text(trp('You can donate again from {date}.',
              {'date': DateFormat('d MMM yyyy').format(d.nextEligible!)}))));
      return;
    }
    try {
      await ref.read(donorRepositoryProvider).setAvailable(d.uid, !d.available);
      m.showSnackBar(SnackBar(
          content: Text(d.available
              ? tr('You are hidden from searches')
              : tr('You are visible to nearby requests'))));
    } catch (_) {
      m.showSnackBar(
          SnackBar(content: Text(tr('Could not update. Check your internet.'))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donor = ref.watch(myDonorProvider).value;
    final count = ref.watch(availableDonorCountProvider).value;

    if (donor == null) {
      return const AppPage(children: [
        SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.red))),
      ]);
    }

    final status = donor.available
        ? tr('Nearby requests will alert you')
        : !donor.eligibleNow
            ? trp('Eligible again on {date}',
                {'date': DateFormat('d MMM yyyy').format(donor.nextEligible!)})
            : tr('Hidden from donor search');

    return AppPage(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldLabel(_greet()),
              Text(donor.name.split(' ').last,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
            ],
          ),
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Avatar(bytes: donor.photoBytes, name: donor.name, radius: 14),
          ),
        ],
      ),
      AppCard(
        dark: true,
        onTap: () => _toggle(context, ref, donor),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Your status'),
                      style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text(donor.available ? tr('Available to donate') : tr('Not available'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(status,
                      style: const TextStyle(fontSize: 13, color: Colors.white70)),
                ],
              ),
            ),
            AppToggle(on: donor.available, onTap: () => _toggle(context, ref, donor)),
          ],
        ),
      ),
      if (donor.blocked)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: context.isDark
                  ? AppColors.red.withValues(alpha: .2)
                  : const Color(0xFFFBE4E2),
              borderRadius: BorderRadius.circular(22)),
          child: Text(
              tr('Your account is restricted by an admin, so you cannot post or answer requests.'),
              style: TextStyle(fontWeight: FontWeight.w700, color: context.accent)),
        ),
      AppCard(
        onTap: () => context.go('/nearby'),
        child: Row(
          children: [
            const BloodDrop(size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trp('{n} donors available now', {'n': count ?? 0}),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  FieldLabel(tr('Open the live map')),
                ],
              ),
            ),
            Text(tr('Map'),
                style: TextStyle(color: context.accent, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      Row(children: [
        Expanded(
            child: _Action(tr('Find donor'), tr('Live map & list'),
                () => context.go('/nearby'))),
        const SizedBox(width: 12),
        Expanded(
            child: _Action(tr('Request blood'), tr('Notify matches'),
                () => context.go('/request'))),
      ]),
      Row(children: [
        Expanded(
            child: _Action(tr('Eligibility'), tr('Can I donate?'),
                () => context.push('/eligibility'))),
        const SizedBox(width: 12),
        Expanded(
            child: _Action(tr('Compatibility'), tr('Who gives to whom'),
                () => context.push('/compatibility'))),
      ]),
      AppCard(
        onTap: () => context.push('/hospitals'),
        child: Row(
          children: [
            Icon(Icons.local_hospital_rounded, color: context.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(tr('Find nearby hospitals'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            Icon(Icons.chevron_right, color: context.textMuted),
          ],
        ),
      ),
      const CampReminderSection(),
      const UrgentSection(),
    ]);
  }
}

class _Action extends StatelessWidget {
  final String title, sub;
  final VoidCallback onTap;
  const _Action(this.title, this.sub, this.onTap);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BloodDrop(size: 20),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          FieldLabel(sub),
        ],
      ),
    );
  }
}