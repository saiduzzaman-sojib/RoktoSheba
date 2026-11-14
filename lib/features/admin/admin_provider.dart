import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/firestore_paths.dart';
import '../auth/providers/auth_provider.dart';

/// True when users/{uid}.role == 'admin'. Step 8 builds on this.
final isAdminProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);
  return FirebaseFirestore.instance
      .collection(FS.users)
      .doc(user.uid)
      .snapshots()
      .map((d) => d.data()?['role'] == 'admin');
});