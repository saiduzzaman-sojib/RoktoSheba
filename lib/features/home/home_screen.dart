import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_toggle.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/blood_drop.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../auth/providers/auth_provider.dart';
import '../donors/models/donor.dart';
import '../donors/providers/donor_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greet() {
    final h = DateTime.now().hour;
    return h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening';
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, Donor d) async {
    final m = ScaffoldMessenger.of(context);
    if (!d.available && !d.eligibleNow) {
      m.showSnackBar(SnackBar(
          content: Text(
              'You can donate again from ${DateFormat('d MMM yyyy').format(d.nextEligible!)}.')));
      return;
    }
    try {
      await ref.read(donorRepositoryProvider).setAvailable(d.uid, !d.available);
      m.showSnackBar(SnackBar(
          content: Text(d.available
              ? 'You are hidden from searches'
              : 'You are visible to nearby requests')));
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Could not update. Check your internet.')));
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
        ? 'Nearby requests will alert you'
        : !donor.eligibleNow
            ? 'Eligible again on ${DateFormat('d MMM yyyy').format(donor.nextEligible!)}'
            : 'Hidden from donor search';

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
                  const Text('Your status',
                      style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text(donor.available ? 'Available to donate' : 'Not available',
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
                  Text('${count ?? 0} donors available now',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const FieldLabel('Open the live map'),
                ],
              ),
            ),
            const Text('Map',
                style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      Row(children: [
        Expanded(child: _Action('Find donor', 'Live map & list', () => context.go('/nearby'))),
        const SizedBox(width: 12),
        Expanded(child: _Action('Request blood', 'Notify matches', () => context.go('/request'))),
      ]),
      Row(children: [
        Expanded(child: _Action('Eligibility', 'Can I donate?', () => context.push('/eligibility'))),
        const SizedBox(width: 12),
        Expanded(child: _Action('Compatibility', 'Who gives to whom', () => context.push('/compatibility'))),
      ]),
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          FieldLabel(sub),
        ],
      ),
    );
  }
}