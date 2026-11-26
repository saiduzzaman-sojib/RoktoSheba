import 'package:flutter/material.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatar.dart';
import '../donors/models/donor.dart';
import '../requests/models/blood_request.dart';
import 'donor_response_model.dart';

class AiInsightsCard extends StatelessWidget {
  final BloodRequest request;
  final List<Donor> donors;
  const AiInsightsCard({super.key, required this.request, required this.donors});

  @override
  Widget build(BuildContext context) {
    final list = rankDonors(donors, request);

    if (list.isEmpty) {
      return AppCard(
        child: Row(children: [
          const Icon(Icons.auto_awesome, size: 18, color: AppColors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(tr('AI insight: no matching donors found yet.'),
                style: TextStyle(color: context.textMuted)),
          ),
        ]),
      );
    }

    final expected = list.fold<double>(0, (s, e) => s + e.probability);
    final top = list.take(3).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.auto_awesome, size: 18, color: AppColors.red),
            const SizedBox(width: 8),
            Text(tr('AI insight'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ]),
          const SizedBox(height: 10),
          Text(
            trp('About {n} of {total} matching donors are likely to respond.',
                {'n': expected.round(), 'total': list.length}),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final e in top) ...[
            Row(children: [
              Avatar(bytes: e.donor.photoBytes, name: e.donor.name, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.donor.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      '${e.donor.bloodGroup} · ${e.km == null ? e.donor.area : trp('{n} km', {'n': e.km!.toStringAsFixed(1)})}',
                      style: TextStyle(fontSize: 12, color: context.textMuted),
                    ),
                  ],
                ),
              ),
              _Pill(e.probability),
            ]),
            const SizedBox(height: 10),
          ],
          Text(
            tr('Model: logistic regression trained on simulated data.'),
            style: TextStyle(fontSize: 11, color: context.textMuted),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final double p;
  const _Pill(this.p);

  @override
  Widget build(BuildContext context) {
    final high = p >= .65, mid = p >= .45;
    final c = high ? AppColors.green : (mid ? Colors.orange : AppColors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('${bnNum((p * 100).round())}%',
          style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 13)),
    );
  }
}