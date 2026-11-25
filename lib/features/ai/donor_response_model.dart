import 'dart:math' as math;
import '../donors/models/donor.dart';
import '../requests/data/request_matching.dart';
import '../requests/models/blood_request.dart';

/// Logistic Regression trained with scikit-learn (see train.py).
/// Feature order must match the training script.
class DonorResponseModel {
  // distance_km, days_since_donation, is_night, is_critical, is_verified, exact_group
  static const _mean = [4.754302, 261.830750, 0.301625, 0.446937, 0.503375, 0.596938];
  static const _scale = [2.855919, 90.909596, 0.458963, 0.497176, 0.499989, 0.490513];
  static const _coef = [-0.660957, 0.063016, -0.400383, 0.305154, 0.248267, 0.157522];
  static const _bias = 0.425619;

  static List<double> features(Donor d, BloodRequest r) {
    final km = (distanceToRequest(d, r) ?? 5.0).clamp(0.2, 10.0).toDouble();
    final days = d.lastDonation == null
        ? 365.0
        : DateTime.now().difference(d.lastDonation!).inDays.clamp(0, 365).toDouble();
    final h = DateTime.now().hour;
    final night = (h >= 22 || h < 6) ? 1.0 : 0.0;
    final critical = r.urgency == 'Critical' ? 1.0 : 0.0;
    final verified = d.verified ? 1.0 : 0.0;
    final exact = d.bloodGroup == r.bloodGroup ? 1.0 : 0.0;
    return [km, days, night, critical, verified, exact];
  }

  /// Probability (0..1) that this donor accepts this request.
  static double predict(Donor d, BloodRequest r) {
    final x = features(d, r);
    var z = _bias;
    for (var i = 0; i < x.length; i++) {
      z += _coef[i] * (x[i] - _mean[i]) / _scale[i];
    }
    return 1 / (1 + math.exp(-z));
  }
}

class RankedDonor {
  final Donor donor;
  final double probability;
  final double? km;
  const RankedDonor(this.donor, this.probability, this.km);
}

/// Matching donors sorted by predicted chance of accepting.
List<RankedDonor> rankDonors(List<Donor> donors, BloodRequest r) {
  final out = <RankedDonor>[
    for (final d in donors)
      if (donorMatchesRequest(d, r))
        RankedDonor(d, DonorResponseModel.predict(d, r), distanceToRequest(d, r)),
  ]..sort((a, b) => b.probability.compareTo(a.probability));
  return out;
}