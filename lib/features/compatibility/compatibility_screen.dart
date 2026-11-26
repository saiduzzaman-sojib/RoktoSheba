import 'package:flutter/material.dart';
import '../../core/constants/blood.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/back_link.dart';
import '../../core/widgets/gradient_scaffold.dart';

class CompatibilityScreen extends StatelessWidget {
  const CompatibilityScreen({super.key});

  static const _order = ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'];

  String _list(List<String> l) =>
      l.length == bloodGroups.length ? tr('All groups') : l.join(', ');

  @override
  Widget build(BuildContext context) {
    return AppPage(navPadding: false, children: [
      const BackLink('Back'),
      Text(tr('Blood compatibility'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      FieldLabel(tr('Who each group can give to, and receive from.')),
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
                      : Border(bottom: BorderSide(color: context.line)),
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
                          Text(trp('Gives to: {list}', {'list': _list(canDonateTo[g]!)}),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(trp('Receives from: {list}', {'list': _list(donorsFor(g))}),
                              style: TextStyle(fontSize: 12, color: context.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      FieldLabel(tr('O- is the universal donor. AB+ is the universal recipient.')),
    ]);
  }
}