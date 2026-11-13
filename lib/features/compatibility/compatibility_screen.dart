import 'package:flutter/material.dart';
import '../../core/constants/blood.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/back_link.dart';
import '../../core/widgets/gradient_scaffold.dart';

class CompatibilityScreen extends StatelessWidget {
  const CompatibilityScreen({super.key});

  static const _order = ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'];

  String _list(List<String> l) => l.length == bloodGroups.length ? 'All groups' : l.join(', ');

  @override
  Widget build(BuildContext context) {
    return AppPage(navPadding: false, children: [
      const BackLink('Back'),
      const Text('Blood compatibility',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      const FieldLabel('Who each group can give to, and receive from.'),
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          children: [
            for (final g in _order)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: g == _order.last
                      ? null
                      : const Border(bottom: BorderSide(color: Color(0xFFF0E8DF))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: AppColors.redGradient,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(g,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gives to: ${_list(canDonateTo[g]!)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('Receives from: ${_list(donorsFor(g))}',
                              style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      const FieldLabel('O- is the universal donor. AB+ is the universal recipient.'),
    ]);
  }
}