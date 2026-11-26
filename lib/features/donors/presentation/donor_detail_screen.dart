import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/distance.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/back_link.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../providers/donor_provider.dart';

class DonorDetailScreen extends ConsumerWidget {
  final String uid;
  const DonorDetailScreen({super.key, required this.uid});

  Widget _row(String a, String b) => AppCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FieldLabel(a),
            Flexible(
                child: Text(b,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w800))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(donorByIdProvider(uid));
    final myLoc = ref.watch(myLocationProvider).value?.point;

    return async.when(
      loading: () => const AppPage(navPadding: false, children: [
        SizedBox(height: 240, child: Center(child: CircularProgressIndicator(color: AppColors.red))),
      ]),
      error: (_, _) => AppPage(navPadding: false, children: [
        const BackLink('Back to map'),
        FieldLabel(tr('Could not load this donor.')),
      ]),
      data: (d) {
        if (d == null) {
          return AppPage(navPadding: false, children: [
            const BackLink('Back to map'),
            FieldLabel(tr('This donor no longer exists.')),
          ]);
        }
        String? dist;
        if (myLoc != null && d.location != null) {
          final km = distanceKm(myLoc.latitude, myLoc.longitude,
              d.location!.latitude, d.location!.longitude);
          dist = trp('{n} km away', {'n': km.toStringAsFixed(1)});
        }
        final ok = d.canBeContacted;
        return AppPage(navPadding: false, children: [
          const BackLink('Back to map'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(children: [
              Stack(clipBehavior: Clip.none, children: [
                Avatar(bytes: d.photoBytes, name: d.name, size: 104, radius: 32),
                Positioned(
                  right: -8,
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        gradient: AppColors.redGradient,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.surface, width: 3)),
                    child: Text(d.bloodGroup,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              Text(d.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              FieldLabel('${d.area}, ${d.district}${dist == null ? '' : ' · $dist'}'),
              const SizedBox(height: 10),
              Text(ok ? tr('Eligible and available') : tr('Busy right now'),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ok ? AppColors.green : context.accent)),
              if (d.verified)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(tr('✓ Verified donor'),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.green)),
                ),
            ]),
          ),
          _row(tr('Last donation'),
              d.lastDonation == null ? tr('Not shared') : fmtDate(d.lastDonation!)),
          _row(tr('Contact number'), tr('Shared after donor accepts')),
          FieldLabel(tr(
              'Phone numbers stay private. The donor gets an alert and decides whether to accept.')),
          AppButton(
            label: tr('Send request to donor'),
            onPressed: ok
                ? () => context.go('/request', extra: {
                      'uid': d.uid,
                      'name': d.name,
                      'group': d.bloodGroup,
                      'ts': '${DateTime.now().millisecondsSinceEpoch}',
                    })
                : null,
          ),
        ]);
      },
    );
  }
}