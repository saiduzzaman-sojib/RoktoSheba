import '../../../core/constants/blood.dart';
import '../../../core/utils/distance.dart';
import '../../donors/models/donor.dart';
import '../models/blood_request.dart';

const matchRadiusKm = 10.0;

/// Can a donor of [donorGroup] give blood to a patient who needs [needed]?
bool bloodCompatible(String donorGroup, String needed) =>
    canDonateTo[donorGroup]?.contains(needed) ?? false;

double? distanceToRequest(Donor d, BloodRequest r) {
  if (d.location == null || r.location == null) return null;
  return distanceKm(d.location!.latitude, d.location!.longitude,
      r.location!.latitude, r.location!.longitude);
}

/// Should this donor be alerted about this request?
bool donorMatchesRequest(Donor d, BloodRequest r) {
  if (d.uid == r.requesterId) return false;
  if (!d.canBeContacted) return false;
  if (!bloodCompatible(d.bloodGroup, r.bloodGroup)) return false;
  if (r.targetDonorId != null) return r.targetDonorId == d.uid;
  final km = distanceToRequest(d, r);
  if (km != null) return km <= matchRadiusKm;
  // No GPS on one side: fall back to the same district.
  return d.district.trim().toLowerCase() == r.district.trim().toLowerCase();
}