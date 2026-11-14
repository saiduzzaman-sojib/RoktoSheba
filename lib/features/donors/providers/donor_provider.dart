import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/services/location_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/donor_repository.dart';
import '../models/donation.dart';
import '../models/donor.dart';

final donorRepositoryProvider =
    Provider<DonorRepository>((ref) => DonorRepository(FirebaseFirestore.instance));

/// The logged-in donor's donation history, newest first.
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
      .map((s) => s.docs.where((d) => d.data()['blocked'] != true).length);;
});

/// All available donors (filtered by distance on the device).
final availableDonorsProvider = StreamProvider<List<Donor>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <Donor>[]);
  return FirebaseFirestore.instance
      .collection(FS.donors)
      .where('available', isEqualTo: true)
      .limit(500)
      .snapshots()
      .map((s) => s.docs.map(Donor.fromDoc).toList());
});

/// One donor by id (live).
final donorByIdProvider = StreamProvider.family<Donor?, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection(FS.donors)
      .doc(uid)
      .snapshots()
      .map((d) => d.exists ? Donor.fromDoc(d) : null);
});

/// Gets the phone's location and saves it to the donor's profile.
/// Re-runs when the logged-in user changes; refresh with ref.invalidate().
final myLocationProvider = FutureProvider<LocResult>((ref) async {
  final user = ref.watch(authStateProvider).value;
  final r = await getMyLocation();
  if (r.point != null && user != null) {
    try {
      await ref
          .read(donorRepositoryProvider)
          .updateLocation(user.uid, r.point!.latitude, r.point!.longitude);
    } catch (_) {}
  }
  return r;
});