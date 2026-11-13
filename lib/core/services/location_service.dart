import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocStatus { ok, serviceOff, denied, deniedForever, error }

class LocResult {
  final LocStatus status;
  final LatLng? point;
  const LocResult(this.status, [this.point]);
}

Future<LocResult> getMyLocation() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocResult(LocStatus.serviceOff);
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.denied) return const LocResult(LocStatus.denied);
    if (p == LocationPermission.deniedForever) {
      return const LocResult(LocStatus.deniedForever);
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
    );
    return LocResult(LocStatus.ok, LatLng(pos.latitude, pos.longitude));
  } catch (_) {
    return const LocResult(LocStatus.error);
  }
}