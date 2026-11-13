import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/request_matching.dart';
import '../data/request_repository.dart';
import '../models/blood_request.dart';

final requestRepositoryProvider =
    Provider<RequestRepository>((ref) => RequestRepository(FirebaseFirestore.instance));

int _newestFirst(BloodRequest a, BloodRequest b) =>
    (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now());

/// All open requests (matching is done on the device).
final openRequestsProvider = StreamProvider<List<BloodRequest>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <BloodRequest>[]);
  return FirebaseFirestore.instance
      .collection(FS.requests)
      .where('status', isEqualTo: 'open')
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(BloodRequest.fromDoc).toList()..sort(_newestFirst));
});

class IncomingRequest {
  final BloodRequest request;
  final double? km;
  const IncomingRequest(this.request, this.km);
}

/// Open requests that need ME (compatible group, available, nearby), newest first.
final incomingRequestsProvider = Provider<List<IncomingRequest>>((ref) {
  final me = ref.watch(myDonorProvider).value;
  final open = ref.watch(openRequestsProvider).value ?? const <BloodRequest>[];
  if (me == null) return const <IncomingRequest>[];
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  final out = <IncomingRequest>[];
  for (final r in open) {
    if ((r.createdAt ?? DateTime.now()).isBefore(cutoff)) continue;
    if (!donorMatchesRequest(me, r)) continue;
    out.add(IncomingRequest(r, distanceToRequest(me, r)));
  }
  return out;
});

/// Requests I posted.
final myRequestsProvider = StreamProvider<List<BloodRequest>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <BloodRequest>[]);
  return FirebaseFirestore.instance
      .collection(FS.requests)
      .where('requesterId', isEqualTo: user.uid)
      .snapshots()
      .map((s) => s.docs.map(BloodRequest.fromDoc).toList()..sort(_newestFirst));
});

final requestProvider = StreamProvider.family<BloodRequest?, String>((ref, id) {
  return FirebaseFirestore.instance
      .collection(FS.requests)
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? BloodRequest.fromDoc(d) : null);
});

/// Donor responses to a request (requester only).
final responsesProvider = StreamProvider.family<List<RequestResponse>, String>((ref, id) {
  return FirebaseFirestore.instance
      .collection(FS.requests)
      .doc(id)
      .collection(FS.responses)
      .snapshots()
      .map((s) => s.docs.map(RequestResponse.fromDoc).toList());
});

/// MY response to a request (donor side).
final myResponseProvider = StreamProvider.family<RequestResponse?, String>((ref, id) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(FS.requests)
      .doc(id)
      .collection(FS.responses)
      .doc(user.uid)
      .snapshots()
      .map((d) => d.exists ? RequestResponse.fromDoc(d) : null);
});

/// The requester's phone. Only readable after I accepted.
final requesterContactProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, id) async {
  try {
    final d = await FirebaseFirestore.instance
        .collection(FS.requests)
        .doc(id)
        .collection(FS.requestPrivate)
        .doc('contact')
        .get();
    return d.data()?['requesterMobile'] as String?;
  } catch (_) {
    return null;
  }
});