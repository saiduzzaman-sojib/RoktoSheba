import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../donors/models/donor.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance));

final authStateProvider = StreamProvider<User?>(
    (ref) => ref.watch(authRepositoryProvider).authStateChanges());

/// The logged-in user's own donor profile (null if logged out).
final myDonorProvider = StreamProvider<Donor?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(FS.donors)
      .doc(user.uid)
      .snapshots()
      .map((d) => d.exists ? Donor.fromDoc(d) : null);
});