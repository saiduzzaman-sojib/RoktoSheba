import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/shimmer.dart';
import '../donors/models/donor.dart';
import '../requests/models/blood_request.dart';
import 'donor_response_model.dart';

class AiInsightsCard extends StatefulWidget {
  final BloodRequest request;
  const AiInsightsCard({super.key, required this.request});

  @override
  State<AiInsightsCard> createState() => _AiInsightsCardState();
}

class _AiInsightsCardState extends State<AiInsightsCard> {
  late final Future<List<RankedDonor>> _future = _load();

  Future<List<RankedDonor>> _load() async {
    final snap = await FirebaseFirestore.instance
        .collection('donors')
        .where('available', isEqualTo: true)
        .get();
    final donors = [
      for (final doc in snap.docs)
        if (doc.data()['blocked'] != true) Donor.fromDoc(doc),
    ];
    return rankDonors(donors, widget.request);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RankedDonor>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Shimmer(child: CardSkeleton());
        }
        final list = snap.data ?? const <RankedDonor>[];
        if (list.isEmpty) {
          return AppCard(
            child: Text('AI insight: no matching donors found yet.',
                style: TextStyle(color: context.textMuted)),
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
                const Text('AI insight',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ]),
              const SizedBox(height: 10),
              Text(
                'About ${expected.round()} of ${list.length} matching donors '
                'are likely to respond.',
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
                          '${e.donor.bloodGroup} · ${e.km == null ? e.donor.area : '${e.km!.toStringAsFixed(1)} km'}',
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
                'Model: logistic regression trained on simulated data.',
                style: TextStyle(fontSize: 11, color: context.textMuted),
              ),
            ],
          ),
        );
      },
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
      child: Text('${(p * 100).round()}%',
          style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 13)),
    );
  }
}