import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Hospital {
  final String name;
  final double lat, lon;
  final String? phone, address;
  final double distanceKm;
  const Hospital({
    required this.name,
    required this.lat,
    required this.lon,
    required this.distanceKm,
    this.phone,
    this.address,
  });
}

class HospitalService {
  static Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Location is turned off. Please turn on GPS.';
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw 'Location permission is needed to find hospitals near you.';
    }
    return Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium));
  }

  static Future<List<Hospital>> nearby(double lat, double lon,
      {int radius = 8000}) async {
    final q = '[out:json][timeout:20];('
        'node["amenity"="hospital"](around:$radius,$lat,$lon);'
        'way["amenity"="hospital"](around:$radius,$lat,$lon);'
        ');out center tags 80;';

    final res = await http
        .post(Uri.parse('https://overpass-api.de/api/interpreter'),
            body: {'data': q})
        .timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw 'Hospital server busy. Try again in a moment.';
    }

    final elements = (jsonDecode(res.body)['elements'] as List?) ?? [];
    final out = <Hospital>[];
    for (final e in elements) {
      final tags = (e['tags'] as Map?)?.cast<String, dynamic>() ?? {};
      final name = (tags['name:en'] ?? tags['name'])?.toString();
      if (name == null || name.trim().isEmpty) continue;

      final c = e['center'] as Map?;
      final hLat = (e['lat'] ?? c?['lat']) as num?;
      final hLon = (e['lon'] ?? c?['lon']) as num?;
      if (hLat == null || hLon == null) continue;

      final addr = [tags['addr:street'], tags['addr:city']]
          .where((x) => x != null && x.toString().isNotEmpty)
          .join(', ');

      out.add(Hospital(
        name: name,
        lat: hLat.toDouble(),
        lon: hLon.toDouble(),
        phone: (tags['phone'] ?? tags['contact:phone'])?.toString(),
        address: addr.isEmpty ? null : addr,
        distanceKm: Geolocator.distanceBetween(
                lat, lon, hLat.toDouble(), hLon.toDouble()) /
            1000,
      ));
    }
    out.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return out;
  }
}