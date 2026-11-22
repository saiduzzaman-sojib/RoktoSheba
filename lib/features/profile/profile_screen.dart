import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/eligibility.dart';
import '../../core/utils/photo.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/area_field.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../admin/admin_provider.dart';
import '../auth/data/auth_repository.dart';
import '../auth/providers/auth_provider.dart';
import '../donors/models/donor.dart';
import '../donors/providers/donor_provider.dart';

final _fmt = DateFormat('d MMM yyyy');

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _changePhoto(BuildContext context, WidgetRef ref, String uid) async {
    final m = ScaffoldMessenger.of(context);
    try {
      final b64 = await pickPhotoB64();
      if (b64 == null) return;
      await ref.read(donorRepositoryProvider).updatePhoto(uid, b64);
      m.showSnackBar(const SnackBar(content: Text('Photo updated')));
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Could not update photo.')));
    }
  }

  Future<void> _logDonation(BuildContext context, WidgetRef ref, String uid) async {
    final m = ScaffoldMessenger.of(context);
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      helpText: 'When did you donate?',
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (d == null) return;
    try {
      await ref.read(donorRepositoryProvider).logDonation(uid, d);
      final next = nextEligibleDate(d)!;
      m.showSnackBar(SnackBar(
          content: Text(next.isAfter(DateTime.now())
              ? 'Thank you! Eligible again on ${_fmt.format(next)}.'
              : 'Donation saved.')));
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Could not save. Check your internet.')));
    }
  }

  void _edit(BuildContext context, Donor d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => _EditSheet(donor: d),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final m = ScaffoldMessenger.of(context);
    final pw = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete your account?'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'This removes your profile and phone number. It cannot be undone. Enter your password to confirm.'),
          const SizedBox(height: 12),
          TextField(
              controller: pw,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Password')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    final password = pw.text;
    pw.dispose();
    if (ok != true) return;
    try {
      await ref.read(authRepositoryProvider).deleteAccount(password);
      m.showSnackBar(const SnackBar(content: Text('Your account was deleted.')));
    } catch (e) {
      m.showSnackBar(SnackBar(content: Text(authErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donor = ref.watch(myDonorProvider).value;
    final donations = ref.watch(myDonationsProvider).value ?? const [];
    final isAdmin = ref.watch(isAdminProvider).value ?? false;

    if (donor == null) {
      return const AppPage(children: [
        SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.red))),
      ]);
    }

    final nextText = donor.lastDonation == null || donor.eligibleNow
        ? 'Now'
        : _fmt.format(donor.nextEligible!);

    return AppPage(children: [
      Row(
        children: [
          GestureDetector(
            onTap: () => _changePhoto(context, ref, donor.uid),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Avatar(bytes: donor.photoBytes, name: donor.name, size: 88, radius: 28),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3)),
                    child: const Icon(Icons.photo_camera, color: Colors.white, size: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donor.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                FieldLabel('Donor, ${donor.area}, ${donor.district}'),
                const SizedBox(height: 4),
                const Text('Tap photo to change',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green)),
              ],
            ),
          ),
        ],
      ),
      AppCard(
        dark: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Blood group',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                Text(donor.bloodGroup,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Next eligible',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                Text(nextText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
      const FieldLabel(
          'Requesters see your photo when you accept, so they can recognise you at the hospital.'),
      AppButton(
          label: 'Log a donation',
          onPressed: () => _logDonation(context, ref, donor.uid)),
      const Text('Donation history',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      if (donations.isEmpty)
        const FieldLabel('No donations logged yet.')
      else
        for (final d in donations)
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.place.isEmpty ? 'Blood donation' : d.place,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    FieldLabel(_fmt.format(d.date)),
                  ],
                ),
                const Text('Completed',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green)),
              ],
            ),
          ),
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            if (isAdmin) _Row('Admin panel', () => context.push('/admin')),
            _Row('Change photo', () => _changePhoto(context, ref, donor.uid)),
            _Row('Edit details', () => _edit(context, donor)),
            _Row('Terms & Privacy', () => context.push('/terms-view')),
            _Row('Delete my account', () => _deleteAccount(context, ref)),
            _Row('Log out', () => ref.read(authRepositoryProvider).signOut()),
          ],
        ),
      ),
    ]);
  }
}

class _Row extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Row(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const Text('>', style: TextStyle(color: AppColors.grey)),
          ],
        ),
      ),
    );
  }
}

class _EditSheet extends ConsumerStatefulWidget {
  final Donor donor;
  const _EditSheet({required this.donor});
  @override
  ConsumerState<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends ConsumerState<_EditSheet> {
  late final _name = TextEditingController(text: widget.donor.name);
  late final _district = TextEditingController(text: widget.donor.district);
  late final _area = TextEditingController(text: widget.donor.area);
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _district.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = _name.text.trim(), d = _district.text.trim(), a = _area.text.trim();
    final m = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    if (n.length < 2 || d.isEmpty || a.isEmpty) {
      m.showSnackBar(const SnackBar(content: Text('Please fill in every field.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(donorRepositoryProvider)
          .updateProfile(widget.donor.uid, name: n, district: d, area: a);
      nav.pop();
      m.showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Could not save. Check your internet.')));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 24, 22, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Edit details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Full name')),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: TextField(
                    controller: _district,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(hintText: 'District'))),
            const SizedBox(width: 10),
            Expanded(child: AreaField(controller: _area)),
          ]),
          const SizedBox(height: 18),
          AppButton(label: 'Save', loading: _busy, onPressed: _save),
        ],
      ),
    );
  }
}