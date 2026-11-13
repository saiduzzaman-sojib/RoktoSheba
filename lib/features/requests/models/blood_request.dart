import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequest {
  final String id, requesterId, requesterName, bloodGroup, hospital, district, area, urgency, status;
  final int units;
  final GeoPoint? location;
  final DateTime? createdAt;
  final String? targetDonorId;

  const BloodRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.bloodGroup,
    required this.hospital,
    required this.district,
    required this.area,
    required this.urgency,
    required this.status,
    required this.units,
    this.location,
    this.createdAt,
    this.targetDonorId,
  });

  bool get isOpen => status == 'open';

  factory BloodRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    final pos = m['position'];
    return BloodRequest(
      id: d.id,
      requesterId: m['requesterId'] ?? '',
      requesterName: m['requesterName'] ?? '',
      bloodGroup: m['bloodGroup'] ?? '',
      hospital: m['hospital'] ?? '',
      district: m['district'] ?? '',
      area: m['area'] ?? '',
      urgency: m['urgency'] ?? 'Critical',
      status: m['status'] ?? 'open',
      units: (m['units'] ?? 1) as int,
      location: pos is Map ? pos['geopoint'] as GeoPoint? : null,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
      targetDonorId: m['targetDonorId'] as String?,
    );
  }
}

class RequestResponse {
  final String donorId, donorName, donorBloodGroup, status;
  final String? donorMobile, donorPhotoB64;
  final DateTime? createdAt;

  const RequestResponse({
    required this.donorId,
    required this.donorName,
    required this.donorBloodGroup,
    required this.status,
    this.donorMobile,
    this.donorPhotoB64,
    this.createdAt,
  });

  bool get accepted => status == 'accepted';

  Uint8List? get photoBytes {
    final p = donorPhotoB64;
    if (p == null || p.isEmpty) return null;
    try {
      return base64Decode(p);
    } catch (_) {
      return null;
    }
  }

  factory RequestResponse.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return RequestResponse(
      donorId: d.id,
      donorName: m['donorName'] ?? '',
      donorBloodGroup: m['donorBloodGroup'] ?? '',
      status: m['status'] ?? 'declined',
      donorMobile: m['donorMobile'] as String?,
      donorPhotoB64: m['donorPhotoB64'] as String?,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

String timeAgo(DateTime? t) {
  if (t == null) return 'just now';
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  return '${d.inDays} d ago';
}