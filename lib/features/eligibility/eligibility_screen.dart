import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/eligibility.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/back_link.dart';
import '../../core/widgets/blood_chip.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../auth/providers/auth_provider.dart';

class EligibilityScreen extends ConsumerStatefulWidget {
  const EligibilityScreen({super.key});
  @override
  ConsumerState<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends ConsumerState<EligibilityScreen> {
  final _age = TextEditingController();
  final _wt = TextEditingController();
  bool _infection = false, _chronic = false, _touched = false;
  DateTime? _last;
  EligibilityRules _rules = const EligibilityRules();
  EligibilityResult? _result;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  @override
  void dispose() {
    _age.dispose();
    _wt.dispose();
    super.dispose();
  }

  // Admin can change the rules in config/eligibility; defaults are used otherwise.
  Future<void> _loadRules() async {
    try {
      final d = await FirebaseFirestore.instance
          .collection(FS.config)
          .doc('eligibility')
          .get();
      if (d.exists && mounted) setState(() => _rules = EligibilityRules.fromMap(d.data()));
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
        context: context,
        initialDate: _last ?? now,
        firstDate: DateTime(now.year - 5),
        lastDate: now);
    if (d != null) {
      setState(() {
        _last = d;
        _touched = true;
      });
    }
  }

  void _check(DateTime? last) {
    final a = int.tryParse(_age.text.trim());
    final w = double.tryParse(_wt.text.trim());
    if (a == null || w == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('Enter your age and weight.'))));
      return;
    }
    setState(() => _result = checkEligibility(
          age: a,
          weight: w,
          lastDonation: last,
          hasInfection: _infection,
          hasChronicCondition: _chronic,
          rules: _rules,
        ));
  }

  Widget _yesNo(String q, bool value, ValueChanged<bool> onChanged) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(q), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            BloodChip(label: tr('Yes'), selected: value, onTap: () => onChanged(true)),
            const SizedBox(width: 8),
            BloodChip(label: tr('No'), selected: !value, onTap: () => onChanged(false)),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final donor = ref.watch(myDonorProvider).value;
    final last = _touched ? _last : donor?.lastDonation;
    final r = _result;
    final dark = context.isDark;

    return AppPage(navPadding: false, children: [
      const BackLink('Back'),
      Text(tr('Can I donate?'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      FieldLabel(tr('Answer a few quick questions.')),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('Your age and weight'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: tr('Age e.g. 25')))),
              const SizedBox(width: 10),
              Expanded(
                  child: TextField(
                      controller: _wt,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(hintText: tr('Kg e.g. 58')))),
            ]),
          ],
        ),
      ),
      AppCard(
        onTap: _pickDate,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                last == null
                    ? tr('Last donation date (tap to set)')
                    : trp('Last donation: {date}', {'date': fmtDate(last)}),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 18, color: context.textMuted),
          ],
        ),
      ),
      _yesNo('Fever, cold or infection now?', _infection, (v) => setState(() => _infection = v)),
      _yesNo('Chronic condition?', _chronic, (v) => setState(() => _chronic = v)),
      if (r != null)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: r.ok
                ? (dark ? AppColors.green.withValues(alpha: .22) : const Color(0xFFE3F3EF))
                : (dark ? AppColors.red.withValues(alpha: .2) : const Color(0xFFFBE4E2)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.ok ? tr('You can donate 🎉') : tr('Not yet eligible'),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: r.ok
                          ? (dark ? const Color(0xFF6FD8C4) : AppColors.green)
                          : context.accent)),
              const SizedBox(height: 6),
              if (r.ok)
                Text(tr('Turn on availability so nearby requests can reach you.'),
                    style: TextStyle(fontSize: 13, color: context.textMain))
              else
                for (final reason in r.reasons)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('• ${tr(reason)}',
                        style: TextStyle(fontSize: 13, color: context.textMain)),
                  ),
            ],
          ),
        ),
      AppButton(label: tr('Check eligibility'), onPressed: () => _check(last)),
    ]);
  }
}