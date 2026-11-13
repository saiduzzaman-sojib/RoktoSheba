import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../../core/utils/eligibility.dart';

class Donor {
  final String uid, name, bloodGroup, district, area;
  final bool available, verified;
  final DateTime? lastDonation;
  final String? photoB64;
  final GeoPoint? location;

  const Donor({
    required this.uid,
    required this.name,
    required this.bloodGroup,
    required this.district,
    required this.area,
    this.available = true,
    this.verified = false,
    this.lastDonation,
    this.photoB64,
    this.location,
  });

  DateTime? get nextEligible => nextEligibleDate(lastDonation);
  bool get eligibleNow =>
      nextEligible == null || !nextEligible!.isAfter(DateTime.now());
  bool get canBeContacted => available && eligibleNow;

  factory Donor.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Donor(
      uid: d.id,
      name: m['name'] ?? '',
      bloodGroup: m['bloodGroup'] ?? '',
      district: m['district'] ?? '',
      area: m['area'] ?? '',
      available: m['available'] ?? true,
      verified: m['verified'] ?? false,
      lastDonation: (m['lastDonation'] as Timestamp?)?.toDate(),
      photoB64: m['photoUrl'],
      location: (m['position']?['geopoint']) as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'bloodGroup': bloodGroup,
        'district': district,
        'area': area,
        'available': available,
        'verified': verified,
        'lastDonation':
            lastDonation == null ? null : Timestamp.fromDate(lastDonation!),
        'photoUrl': photoB64,
        if (location != null) 'position': GeoFirePoint(location!).data,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}