import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../models/blood_request.dart';
import '../providers/request_provider.dart';

Future<void> callNumber(String n) => launchUrl(Uri(scheme: 'tel', path: n));
Future<void> smsNumber(String n) => launchUrl(Uri(scheme: 'sms', path: n));

class ContactButtons extends StatelessWidget {
  final String number;
  const ContactButtons(this.number, {super.key});

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
      );

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(Icons.call, () => callNumber(number)),
        const SizedBox(width: 8),
        _btn(Icons.sms, () => smsNumber(number)),
      ]);
}

class GroupBadge extends StatelessWidget {
  final String group;
  final double size;
  const GroupBadge(this.group, {super.key, this.size = 46});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: AppColors.redGradient,
            borderRadius: BorderRadius.circular(size * .3)),
        child: Text(group,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * .32)),
      );
}

class RequestTile extends ConsumerWidget {
  final BloodRequest r;
  final double? km;
  final bool mine;
  const RequestTile({super.key, required this.r, this.km, this.mine = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String trail;
    Color color;
    if (mine) {
      trail = r.isOpen ? 'Open' : r.status == 'fulfilled' ? 'Fulfilled' : 'Cancelled';
      color = r.isOpen ? AppColors.red : r.status == 'fulfilled' ? AppColors.green : AppColors.grey;
    } else {
      final resp = ref.watch(myResponseProvider(r.id)).value;
      if (resp == null) {
        trail = 'Respond';
        color = AppColors.red;
      } else if (resp.accepted) {
        trail = 'Accepted ✓';
        color = AppColors.green;
      } else {
        trail = 'Declined';
        color = AppColors.grey;
      }
    }
    final k = km;
    final parts = <String>[
      '${r.units} unit${r.units == 1 ? '' : 's'}',
      r.urgency,
      if (k != null) '${k.toStringAsFixed(1)} km',
      timeAgo(r.createdAt),
    ];
    return AppCard(
      onTap: () => context.push('/request/${r.id}'),
      child: Row(children: [
        GroupBadge(r.bloodGroup),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.hospital,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            FieldLabel(parts.join(' · ')),
          ]),
        ),
        const SizedBox(width: 8),
        Text(trail, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

/// "Urgent near you" block on the Home screen.
class UrgentSection extends ConsumerWidget {
  const UrgentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(incomingRequestsProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Urgent near you',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      if (list.isEmpty)
        const AppCard(child: FieldLabel('No open requests need your blood group right now.'))
      else
        for (final i in list.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RequestTile(r: i.request, km: i.km),
          ),
    ]);
  }
}