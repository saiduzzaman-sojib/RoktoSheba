import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/donor_repository.dart';
import '../models/donation.dart';

final donorRepositoryProvider =
    Provider<DonorRepository>((ref) => DonorRepository(FirebaseFirestore.instance));

/// The logged-in donor's donation history, newest first.
/// (Sorted here so no Firestore composite index is needed.)
final myDonationsProvider = StreamProvider<List<Donation>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <Donation>[]);
  return FirebaseFirestore.instance
      .collection(FS.donations)
      .where('donorId', isEqualTo: user.uid)
      .snapshots()
      .map((s) {
    final list = s.docs.map(Donation.fromDoc).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  });
});

/// How many donors are marked available right now.
final availableDonorCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(0);
  return FirebaseFirestore.instance
      .collection(FS.donors)
      .where('available', isEqualTo: true)
      .snapshots()
      .map((s) => s.size);
});