import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roktosheba/features/safety/report_button.dart';
import '../../../core/l10n/l10n.dart';
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
            Text(
                trp(r.units == 1 ? '{n} unit · {urgency}' : '{n} units · {urgency}',
                    {'n': r.units, 'urgency': tr(r.urgency)}),
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
      error: (_, _) => AppPage(navPadding: false, children: [
        const BackLink('Back'),
        FieldLabel(tr('Could not load this request.')),
      ]),
      data: (r) {
        if (r == null) {
          return AppPage(navPadding: false, children: [
            const BackLink('Back'),
            FieldLabel(tr('This request no longer exists.')),
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
        title: Text(tr('Cancel this request?')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr('No'))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(tr('Yes, cancel'))),
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
    if (!ok) m.showSnackBar(SnackBar(content: Text(tr('Could not open WhatsApp.'))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responses = ref.watch(responsesProvider(r.id)).value ?? const <RequestResponse>[];
    final accepted = responses.where((e) => e.accepted).toList();
    final donors = ref.watch(availableDonorsProvider).value ?? const <Donor>[];
    final alerted = donors.where((d) => donorMatchesRequest(d, r)).length;
    final progress = (accepted.length / r.units).clamp(0.0, 1.0);
    final statusText = tr(r.isOpen ? 'Open' : r.status == 'fulfilled' ? 'Fulfilled' : 'Cancelled');

    return AppPage(navPadding: false, children: [
      const BackLink('Back'),
      _header(r),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
                trp('{n} of {total} donors accepted',
                    {'n': accepted.length, 'total': r.units}),
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
                  ? tr('Waiting for the donor you asked.')
                  : trp(
                      alerted == 1
                          ? '{n} compatible donor nearby has been alerted.'
                          : '{n} compatible donors nearby have been alerted.',
                      {'n': alerted}))
              : tr('This request is closed.')),
        ]),
      ),
      if (r.isOpen && r.targetDonorId == null)
        AiInsightsCard(request: r, donors: donors),
      if (r.isOpen)
        OutlinedButton.icon(
          onPressed: () => _share(context),
          icon: const Icon(Icons.share, size: 18),
          label: Text(tr('Share on WhatsApp')),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: context.textMain,
            side: BorderSide(color: context.line),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      if (accepted.isEmpty && r.isOpen)
        FieldLabel(tr('Waiting for donors to accept. Their contact appears here when they do.')),
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
                  label: Text(tr('WhatsApp')),
                ),
              ),
          ]),
        ),
      if (r.isOpen) ...[
        AppButton(
          label: tr('Mark as fulfilled'),
          onPressed: () => ref.read(requestRepositoryProvider).setStatus(r.id, 'fulfilled'),
        ),
        Center(
          child: TextButton(
            onPressed: () => _cancel(context, ref),
            child: Text(tr('Cancel request'),
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
            content: Text(trp('{group} blood cannot be given to {need}.',
                {'group': me.bloodGroup, 'need': r.bloodGroup}))));
        return;
      }
      if (!me.canBeContacted) {
        m.showSnackBar(SnackBar(
            content: Text(!me.eligibleNow
                ? trp('You can donate again from {date}.',
                    {'date': fmtDate(me.nextEligible!)})
                : tr('Turn on availability on the Home screen first.'))));
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
          content: Text(accept
              ? tr('Thank you! The requester was notified.')
              : tr('Request declined.'))));
    } catch (_) {
      m.showSnackBar(SnackBar(content: Text(tr('Could not send. Check your internet.'))));
    }
  }

  Future<void> _logDonation(BuildContext context, WidgetRef ref, Donor me) async {
    final m = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(donorRepositoryProvider)
          .logDonation(me.uid, DateTime.now(), place: r.hospital, requestId: r.id);
      m.showSnackBar(SnackBar(content: Text(tr('Donation logged. Thank you!'))));
    } catch (_) {
      m.showSnackBar(SnackBar(content: Text(tr('Could not save. Check your internet.'))));
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
      _infoRow(tr('Requested by'), r.requesterName),
      if (km != null)
        _infoRow(tr('Distance'), trp('{n} km away', {'n': km.toStringAsFixed(1)})),
      _infoRow(tr('Posted'), timeAgoTr(r.createdAt)),
       ReportButton(type: 'request', targetId: r.id, targetUserId: r.requesterId),
      if (accepted) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: context.isDark
                  ? AppColors.green.withValues(alpha: .22)
                  : const Color(0xFFE3F3EF),
              borderRadius: BorderRadius.circular(22)),
          child: Text(tr('You accepted this request. Thank you! 🎉'),
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: context.isDark ? const Color(0xFF6FD8C4) : AppColors.green)),
        ),
        _Contact(r.id, r.requesterName),
        if (r.status == 'fulfilled' && me != null)
          logged
              ? FieldLabel(tr('Donation logged ✓'))
              : AppButton(
                  label: tr('I donated, log it'),
                  onPressed: () => _logDonation(context, ref, me)),
      ] else if (!r.isOpen)
        FieldLabel(r.status == 'fulfilled'
            ? tr('This request was fulfilled.')
            : tr('This request was cancelled.'))
      else if (me != null) ...[
        if (resp != null) FieldLabel(tr('You declined this request. You can still accept.')),
        AppButton(
            label: tr('Accept & share my contact'),
            onPressed: () => _respond(context, ref, me, true)),
        if (resp == null)
          Center(
            child: TextButton(
              onPressed: () => _respond(context, ref, me, false),
              child: Text(tr('Not now'),
                  style: TextStyle(color: context.textMuted, fontWeight: FontWeight.w800)),
            ),
          ),
        FieldLabel(tr(
            'Your phone number is shared only if you accept, and only with this requester.')),
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
            FieldLabel(tr('Requester contact')),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(phone ?? tr('Loading...'), style: TextStyle(color: context.textMuted)),
          ]),
        ),
        if (phone != null && phone.isNotEmpty) ContactButtons(phone),
      ]),
    );
  }
}