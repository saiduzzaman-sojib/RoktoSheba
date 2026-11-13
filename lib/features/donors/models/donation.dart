import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final String id, place;
  final DateTime date;
  final String? requestId;
  const Donation({required this.id, required this.place, required this.date, this.requestId});

  factory Donation.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return Donation(
      id: d.id,
      place: (m['place'] ?? '') as String,
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      requestId: m['requestId'] as String?,
    );
  }
}