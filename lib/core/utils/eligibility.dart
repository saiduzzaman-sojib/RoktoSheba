/// Waiting period between donations. The admin can change it in config/eligibility;
/// admin_provider.dart keeps this value in sync.
int globalGapDays = 90;

class EligibilityRules {
  final int minAge, maxAge, gapDays;
  final double minWeight;
  const EligibilityRules(
      {this.minAge = 18, this.maxAge = 60, this.minWeight = 50, this.gapDays = 90});

  factory EligibilityRules.fromMap(Map<String, dynamic>? m) => m == null
      ? const EligibilityRules()
      : EligibilityRules(
          minAge: ((m['minAge'] ?? 18) as num).toInt(),
          maxAge: ((m['maxAge'] ?? 60) as num).toInt(),
          minWeight: ((m['minWeight'] ?? 50) as num).toDouble(),
          gapDays: ((m['gapDays'] ?? 90) as num).toInt(),
        );
}

class EligibilityResult {
  final bool ok;
  final List<String> reasons;
  const EligibilityResult(this.ok, this.reasons);
}

DateTime? nextEligibleDate(DateTime? lastDonation, {int? gapDays}) =>
    lastDonation?.add(Duration(days: gapDays ?? globalGapDays));

EligibilityResult checkEligibility({
  required int age,
  required double weight,
  DateTime? lastDonation,
  bool hasInfection = false,
  bool hasChronicCondition = false,
  EligibilityRules rules = const EligibilityRules(),
}) {
  final r = <String>[];
  if (age < rules.minAge || age > rules.maxAge) {
    r.add('Donors must be ${rules.minAge} to ${rules.maxAge} years old.');
  }
  if (weight < rules.minWeight) {
    r.add('Minimum weight is ${rules.minWeight.toStringAsFixed(0)} kg.');
  }
  final next = nextEligibleDate(lastDonation, gapDays: rules.gapDays);
  if (next != null && next.isAfter(DateTime.now())) {
    r.add('Wait until ${next.day}/${next.month}/${next.year} '
        '(${rules.gapDays} days after your last donation).');
  }
  if (hasInfection) r.add('Wait until you have fully recovered.');
  if (hasChronicCondition) r.add('Please ask a doctor before donating.');
  return EligibilityResult(r.isEmpty, r);
}