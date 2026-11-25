import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/share_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/back_link.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../ai/ai_insights_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../donors/models/donation.dart';
import '../../donors/models/donor.dart';
import '../../donors/providers/donor_provider.dart';
import '../data/request_matching.dart';
import '../models/blood_request.dart';
import '../providers/request_provider.dart';
import 'request_widgets.dart';

Widget _header(BloodRequest r) => AppCard(
      dark: true,
      child: Row(children: [
        GroupBadge(r.bloodGroup, size: 56),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${r.units} unit${r.units == 1 ? '' : 's'} · ${r.urgency}',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
            Text(r.hospital,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text('${r.area.isEmpty ? '' : '${r.area}, '}${r.district}',
                style: const TextStyle(fontSize: 13, color: Colors.white70)),
          ]),
        ),
      ]),
    );

Widget _infoRow(String a, String b) => AppCard(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        FieldLabel(a),
        Flexible(
            child: Text(b,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w800))),
      ]),
    );

class RequestStatusScreen extends ConsumerWidget {
  final String id;
  const RequestStatusScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(requestProvider(id));
    final me = ref.watch(authStateProvider).value?.uid;
    return async.when(
      loading: () => const AppPage(navPadding: false, children: [
        SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator(color: AppColors.red))),
      ]),
      error: (_, _) => const AppPage(navPadding: false, children: [
        BackLink('Back'),
        FieldLabel('Could not load this request.'),
      ]),
      data: (r) {
        if (r == null) {
          return const AppPage(navPadding: false, children: [
            BackLink('Back'),
            FieldLabel('This request no longer exists.'),
          ]);
        }
        return r.requesterId == me ? _RequesterView(r) : _DonorView(r);
      },
    );
  }
}

// ---------------------------------------------------------------- requester

class _RequesterView extends ConsumerWidget {
  final BloodRequest r;
  const _RequesterView(this.r);

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Cancel this request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes, cancel')),
        ],
      ),
    );
    if (ok == true) await ref.read(requestRepositoryProvider).setStatus(r.id, 'cancelled');
  }

  Future<void> _share(BuildContext context) async {
    final m = ScaffoldMessenger.of(context);
    final ok = await ShareUtils.whatsApp(ShareUtils.requestText(
      bloodGroup: r.bloodGroup,
      units: r.units,
      hospital: r.hospital,
      area: r.area,
      district: r.district,
      urgency: r.urgency,
    ));
    if (!ok) m.showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responses = ref.watch(responsesProvider(r.id)).value ?? const <RequestResponse>[];
    final accepted = responses.where((e) => e.accepted).toList();
    final donors = ref.watch(availableDonorsProvider).value ?? const <Donor>[];
    final alerted = donors.where((d) => donorMatchesRequest(d, r)).length;
    final progress = (accepted.length / r.units).clamp(0.0, 1.0);
    final statusText = r.isOpen ? 'Open' : r.status == 'fulfilled' ? 'Fulfilled' : 'Cancelled';

    return AppPage(navPadding: false, children: [
      const BackLink('Back'),
      _header(r),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${accepted.length} of ${r.units} donors accepted',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(statusText,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: r.isOpen ? context.accent : AppColors.green)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.line,
              color: AppColors.red,
            ),
          ),
          const SizedBox(height: 10),
          FieldLabel(r.isOpen
              ? (r.targetDonorId != null
                  ? 'Waiting for the donor you asked.'
                  : '$alerted compatible donor${alerted == 1 ? '' : 's'} nearby ${alerted == 1 ? 'has' : 'have'} been alerted.')
              : 'This request is closed.'),
        ]),
      ),
      if (r.isOpen && r.targetDonorId == null)
        AiInsightsCard(request: r, donors: donors),
      if (r.isOpen)
        OutlinedButton.icon(
          onPressed: () => _share(context),
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Share on WhatsApp'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: context.textMain,
            side: BorderSide(color: context.line),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      if (accepted.isEmpty && r.isOpen)
        const FieldLabel('Waiting for donors to accept. Their contact appears here when they do.'),
      for (final a in accepted)
        AppCard(
          child: Column(children: [
            Row(children: [
              Avatar(bytes: a.photoBytes, name: a.donorName, size: 48, radius: 15),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${a.donorName} ${a.donorBloodGroup}',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  FieldLabel(a.donorMobile ?? ''),
                ]),
              ),
              if ((a.donorMobile ?? '').isNotEmpty) ContactButtons(a.donorMobile!),
            ]),
            if ((a.donorMobile ?? '').isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => ShareUtils.whatsApp(
                    'Assalamu alaikum ${a.donorName}, thank you for accepting my '
                    'blood request for ${r.bloodGroup} at ${r.hospital}. 🙏',
                    phone: a.donorMobile,
                  ),
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('WhatsApp'),
                ),
              ),
          ]),
        ),
      if (r.isOpen) ...[
        AppButton(
          label: 'Mark as fulfilled',
          onPressed: () => ref.read(requestRepositoryProvider).setStatus(r.id, 'fulfilled'),
        ),
        Center(
          child: TextButton(
            onPressed: () => _cancel(context, ref),
            child: Text('Cancel request',
                style: TextStyle(color: context.accent, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    ]);
  }
}

// -------------------------------------------------------------------- donor

class _DonorView extends ConsumerWidget {
  final BloodRequest r;
  const _DonorView(this.r);

  Future<void> _respond(BuildContext context, WidgetRef ref, Donor me, bool accept) async {
    final m = ScaffoldMessenger.of(context);
    if (accept) {
      if (!bloodCompatible(me.bloodGroup, r.bloodGroup)) {
        m.showSnackBar(SnackBar(
            content: Text('${me.bloodGroup} blood cannot be given to ${r.bloodGroup}.')));
        return;
      }
      if (!me.canBeContacted) {
        m.showSnackBar(SnackBar(
            content: Text(!me.eligibleNow
                ? 'You can donate again from ${DateFormat('d MMM yyyy').format(me.nextEligible!)}.'
                : 'Turn on availability on the Home screen first.')));
        return;
      }
    }
    try {
      await ref.read(requestRepositoryProvider).respond(
            requestId: r.id,
            uid: me.uid,
            name: me.name,
            bloodGroup: me.bloodGroup,
            photoB64: me.photoB64,
            accept: accept,
          );
      m.showSnackBar(SnackBar(
          content: Text(accept ? 'Thank you! The requester was notified.' : 'Request declined.')));
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Could not send. Check your internet.')));
    }
  }

  Future<void> _logDonation(BuildContext context, WidgetRef ref, Donor me) async {
    final m = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(donorRepositoryProvider)
          .logDonation(me.uid, DateTime.now(), place: r.hospital, requestId: r.id);
      m.showSnackBar(const SnackBar(content: Text('Donation logged. Thank you!')));
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Could not save. Check your internet.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(myDonorProvider).value;
    final resp = ref.watch(myResponseProvider(r.id)).value;
    final donations = ref.watch(myDonationsProvider).value ?? const <Donation>[];
    final logged = donations.any((d) => d.requestId == r.id);
    final km = me == null ? null : distanceToRequest(me, r);
    final accepted = resp?.accepted == true;

    return AppPage(navPadding: false, children: [
      const BackLink('Back'),
      _header(r),
      _infoRow('Requested by', r.requesterName),
      if (km != null) _infoRow('Distance', '${km.toStringAsFixed(1)} km away'),
      _infoRow('Posted', timeAgo(r.createdAt)),
      if (accepted) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: context.isDark
                  ? AppColors.green.withValues(alpha: .22)
                  : const Color(0xFFE3F3EF),
              borderRadius: BorderRadius.circular(22)),
          child: Text('You accepted this request. Thank you! 🎉',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: context.isDark ? const Color(0xFF6FD8C4) : AppColors.green)),
        ),
        _Contact(r.id, r.requesterName),
        if (r.status == 'fulfilled' && me != null)
          logged
              ? const FieldLabel('Donation logged ✓')
              : AppButton(
                  label: 'I donated, log it', onPressed: () => _logDonation(context, ref, me)),
      ] else if (!r.isOpen)
        FieldLabel(r.status == 'fulfilled'
            ? 'This request was fulfilled.'
            : 'This request was cancelled.')
      else if (me != null) ...[
        if (resp != null) const FieldLabel('You declined this request. You can still accept.'),
        AppButton(label: 'Accept & share my contact', onPressed: () => _respond(context, ref, me, true)),
        if (resp == null)
          Center(
            child: TextButton(
              onPressed: () => _respond(context, ref, me, false),
              child: Text('Not now',
                  style: TextStyle(color: context.textMuted, fontWeight: FontWeight.w800)),
            ),
          ),
        const FieldLabel(
            'Your phone number is shared only if you accept, and only with this requester.'),
      ],
    ]);
  }
}

class _Contact extends ConsumerWidget {
  final String requestId, name;
  const _Contact(this.requestId, this.name);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phone = ref.watch(requesterContactProvider(requestId)).value;
    return AppCard(
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const FieldLabel('Requester contact'),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(phone ?? 'Loading...', style: TextStyle(color: context.textMuted)),
          ]),
        ),
        if (phone != null && phone.isNotEmpty) ContactButtons(phone),
      ]),
    );
  }
}