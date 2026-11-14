import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_paths.dart';

class AdminRepository {
  AdminRepository(this._db);
  final FirebaseFirestore _db;

  Future<void> setVerified(String uid, bool value) =>
      _db.collection(FS.donors).doc(uid).update({'verified': value});

  /// Blocking hides the donor and cancels their open requests.
  Future<void> setBlocked(String uid, bool blocked) async {
    final batch = _db.batch();
    batch.update(_db.collection(FS.donors).doc(uid), {
      'blocked': blocked,
      if (blocked) 'available': false,
    });
    if (blocked) {
      final open = await _db
          .collection(FS.requests)
          .where('requesterId', isEqualTo: uid)
          .where('status', isEqualTo: 'open')
          .get();
      for (final d in open.docs) {
        batch.update(d.reference, {'status': 'cancelled'});
      }
    }
    await batch.commit();
  }

  Future<void> saveCamp(String? id, Map<String, dynamic> data) {
    final col = _db.collection(FS.camps);
    return (id == null ? col.doc() : col.doc(id)).set(data);
  }

  Future<void> deleteCamp(String id) => _db.collection(FS.camps).doc(id).delete();

  Future<void> saveBlog(String? id, Map<String, dynamic> data) {
    final col = _db.collection(FS.blogs);
    return (id == null ? col.doc() : col.doc(id)).set(data);
  }

  Future<void> deleteBlog(String id) => _db.collection(FS.blogs).doc(id).delete();

  Future<void> saveRules(Map<String, dynamic> data) => _db
      .collection(FS.config)
      .doc('eligibility')
      .set(data, SetOptions(merge: true));
}