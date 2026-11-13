import 'dart:convert';
import 'dart:typed_data';

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

  /// Decoded photo for Image.memory(), or null if there is no photo.
  Uint8List? get photoBytes {
    final p = photoB64;
    if (p == null || p.isEmpty) return null;
    try {
      return base64Decode(p);
    } catch (_) {
      return null;
    }
  }

  factory Donor.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    final pos = m['position'];
    return Donor(
      uid: d.id,
      name: m['name'] ?? '',
      bloodGroup: m['bloodGroup'] ?? '',
      district: m['district'] ?? '',
      area: m['area'] ?? '',
      available: m['available'] ?? true,
      verified: m['verified'] ?? false,
      lastDonation: (m['lastDonation'] as Timestamp?)?.toDate(),
      photoB64: m['photoB64'] as String?,
      location: pos is Map ? pos['geopoint'] as GeoPoint? : null,
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
        'photoB64': photoB64,
        if (location != null) 'position': GeoFirePoint(location!).data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Donor copyWith({
    String? name,
    String? bloodGroup,
    String? district,
    String? area,
    bool? available,
    bool? verified,
    DateTime? lastDonation,
    String? photoB64,
    GeoPoint? location,
  }) =>
      Donor(
        uid: uid,
        name: name ?? this.name,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        district: district ?? this.district,
        area: area ?? this.area,
        available: available ?? this.available,
        verified: verified ?? this.verified,
        lastDonation: lastDonation ?? this.lastDonation,
        photoB64: photoB64 ?? this.photoB64,
        location: location ?? this.location,
      );
}