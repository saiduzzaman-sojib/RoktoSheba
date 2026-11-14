import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/utils/eligibility.dart';
import '../auth/providers/auth_provider.dart';
import '../donors/models/donor.dart';
import 'admin_repository.dart';

/// True when users/{uid}.role == 'admin'.
final isAdminProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);
  return FirebaseFirestore.instance
      .collection(FS.users)
      .doc(user.uid)
      .snapshots()
      .map((d) => d.data()?['role'] == 'admin');
});

final adminRepositoryProvider =
    Provider<AdminRepository>((ref) => AdminRepository(FirebaseFirestore.instance));

/// Live eligibility rules. Also keeps the app-wide waiting period in sync.
final eligibilityRulesProvider = StreamProvider<EligibilityRules>((ref) {
  return FirebaseFirestore.instance
      .collection(FS.config)
      .doc('eligibility')
      .snapshots()
      .map((d) {
    final r = EligibilityRules.fromMap(d.data());
    globalGapDays = r.gapDays;
    return r;
  });
});

/// Every donor (admin only).
final allDonorsProvider = StreamProvider<List<Donor>>((ref) {
  final admin = ref.watch(isAdminProvider).value ?? false;
  if (!admin) return Stream.value(const <Donor>[]);
  return FirebaseFirestore.instance
      .collection(FS.donors)
      .limit(1000)
      .snapshots()
      .map((s) => s.docs.map(Donor.fromDoc).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
});

class AdminStats {
  final int requests, openRequests, fulfilled, donations;
  const AdminStats(this.requests, this.openRequests, this.fulfilled, this.donations);
}

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) async {
  final db = FirebaseFirestore.instance;
  Future<int> count(Query<Map<String, dynamic>> q) async =>
      (await q.count().get()).count ?? 0;
  final reqs = db.collection(FS.requests);
  final results = await Future.wait([
    count(reqs),
    count(reqs.where('status', isEqualTo: 'open')),
    count(reqs.where('status', isEqualTo: 'fulfilled')),
    count(db.collection(FS.donations)),
  ]);
  return AdminStats(results[0], results[1], results[2], results[3]);
});