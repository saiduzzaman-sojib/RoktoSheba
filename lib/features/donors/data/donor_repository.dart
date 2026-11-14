import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/utils/eligibility.dart';
import '../../../core/constants/dhaka_areas.dart';

class DonorRepository {
  DonorRepository(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _donor(String uid) =>
      _db.collection(FS.donors).doc(uid);

  Future<void> setAvailable(String uid, bool value) => _donor(uid)
      .update({'available': value, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> updatePhoto(String uid, String b64) => _donor(uid)
      .update({'photoB64': b64, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> updateProfile(String uid,
      {required String name, required String district, required String area}) async {
    final batch = _db.batch();
    final ap = areaPoint(area);
    batch.update(_donor(uid), {
      'name': name,
      'district': district,
      'area': area,
      if (ap != null) 'position': GeoFirePoint(GeoPoint(ap.latitude, ap.longitude)).data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection(FS.users).doc(uid), {'name': name});
    await batch.commit();
  }

  /// Saves a donation and starts the waiting period.
  Future<void> logDonation(String uid, DateTime date,
      {String place = '', String? requestId}) async {
    final next = nextEligibleDate(date)!;
    final stillWaiting = next.isAfter(DateTime.now());
    final batch = _db.batch();
    batch.update(_donor(uid), {
      'lastDonation': Timestamp.fromDate(date),
      if (stillWaiting) 'available': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection(FS.donations).doc(), {
      'donorId': uid,
      'requestId': requestId,
      'date': Timestamp.fromDate(date),
      'place': place,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// Saves the donor's position, rounded to ~100 m for privacy.
  Future<void> updateLocation(String uid, double lat, double lng) {
    double r(double v) => (v * 1000).round() / 1000;
    final point = GeoPoint(r(lat), r(lng));
    return _donor(uid).update({
      'position': GeoFirePoint(point).data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}