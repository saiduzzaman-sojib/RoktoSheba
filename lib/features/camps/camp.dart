import 'package:cloud_firestore/cloud_firestore.dart';

class Camp {
  final String id, title, place, organizer, district, description;
  final DateTime date;
  final GeoPoint? location;

  const Camp({
    required this.id,
    required this.title,
    required this.place,
    required this.organizer,
    required this.district,
    required this.description,
    required this.date,
    this.location,
  });

  factory Camp.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return Camp(
      id: d.id,
      title: m['title'] ?? '',
      place: m['place'] ?? '',
      organizer: m['organizer'] ?? '',
      district: m['district'] ?? '',
      description: m['description'] ?? '',
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: m['location'] as GeoPoint?,
    );
  }
}