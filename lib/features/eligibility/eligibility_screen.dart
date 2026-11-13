import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/firestore_paths.dart';
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
    if (d != null) setState(() {
      _last = d;
      _touched = true;
    });
  }

  void _check(DateTime? last) {
    final a = int.tryParse(_age.text.trim());
    final w = double.tryParse(_wt.text.trim());
    if (a == null || w == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter your age and weight.')));
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
          Text(q, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            BloodChip(label: 'Yes', selected: value, onTap: () => onChanged(true)),
            const SizedBox(width: 8),
            BloodChip(label: 'No', selected: !value, onTap: () => onChanged(false)),
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

    return AppPage(navPadding: false, children: [
      const BackLink('Back'),
      const Text('Can I donate?',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      const FieldLabel('Answer a few quick questions.'),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your age and weight',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Age e.g. 25'))),
              const SizedBox(width: 10),
              Expanded(
                  child: TextField(
                      controller: _wt,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'Kg e.g. 58'))),
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
                    ? 'Last donation date (tap to set)'
                    : 'Last donation: ${DateFormat('d MMM yyyy').format(last)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.grey),
          ],
        ),
      ),
      _yesNo('Fever, cold or infection now?', _infection, (v) => setState(() => _infection = v)),
      _yesNo('Chronic condition?', _chronic, (v) => setState(() => _chronic = v)),
      if (r != null)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: r.ok ? const Color(0xFFE3F3EF) : const Color(0xFFFBE4E2),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.ok ? 'You can donate 🎉' : 'Not yet eligible',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: r.ok ? AppColors.green : AppColors.red)),
              const SizedBox(height: 6),
              if (r.ok)
                const Text('Turn on availability so nearby requests can reach you.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF3F3A44)))
              else
                for (final reason in r.reasons)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('• $reason',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF3F3A44))),
                  ),
            ],
          ),
        ),
      AppButton(label: 'Check eligibility', onPressed: () => _check(last)),
    ]);
  }
}