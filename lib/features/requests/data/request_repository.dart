import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../../core/constants/firestore_paths.dart';

/// Thrown when the user posted a request in the last few minutes.
class RateLimitedException implements Exception {
  const RateLimitedException();
}

class RequestRepository {
  RequestRepository(this._db);
  final FirebaseFirestore _db;

  Future<String> create({
    required String uid,
    required String name,
    required String bloodGroup,
    required String hospital,
    required String district,
    required String area,
    required int units,
    required String urgency,
    GeoPoint? location,
    String? targetDonorId,
  }) async {
    final mine = await _db.collection(FS.donorPrivate).doc(uid).get();
    final mobile = (mine.data()?['mobile'] ?? '') as String;

    final ref = _db.collection(FS.requests).doc();

    // The request and the cooldown stamp go in one batch. The rules reject the
    // whole batch if the user posted less than 5 minutes ago.
    final batch = _db.batch();
    batch.set(ref, {
      'requesterId': uid,
      'requesterName': name,
      'bloodGroup': bloodGroup,
      'hospital': hospital,
      'district': district,
      'area': area,
      'units': units,
      'urgency': urgency,
      'status': 'open',
      'targetDonorId': targetDonorId,
      if (location != null) 'position': GeoFirePoint(location).data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection('rate_limits').doc(uid),
        {'lastAt': FieldValue.serverTimestamp()});
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const RateLimitedException();
      rethrow;
    }

    // Written after the request exists (the rules look the request up).
    try {
      await ref
          .collection(FS.requestPrivate)
          .doc('contact')
          .set({'requesterMobile': mobile});
    } catch (e) {
      await ref.delete();
      rethrow;
    }
    return ref.id;
  }

  Future<void> respond({
    required String requestId,
    required String uid,
    required String name,
    required String bloodGroup,
    String? photoB64,
    required bool accept,
  }) async {
    String? mobile;
    if (accept) {
      final d = await _db.collection(FS.donorPrivate).doc(uid).get();
      mobile = d.data()?['mobile'] as String?;
    }
    await _db
        .collection(FS.requests)
        .doc(requestId)
        .collection(FS.responses)
        .doc(uid)
        .set({
      'status': accept ? 'accepted' : 'declined',
      'donorName': name,
      'donorBloodGroup': bloodGroup,
      'donorMobile': mobile,
      'donorPhotoB64': accept ? photoB64 : null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setStatus(String requestId, String status) =>
      _db.collection(FS.requests).doc(requestId).update({'status': status});
}