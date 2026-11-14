import 'package:latlong2/latlong.dart';
import '../../features/donors/models/donor.dart';

/// Approximate centres of common Dhaka areas (lowercase name -> lat, lng).
const _areas = <String, List<double>>{
  'mohakhali': [23.7781, 90.4048],
  'farmgate': [23.7588, 90.3892],
  'gulshan': [23.7925, 90.4078],
  'banani': [23.7937, 90.4066],
  'dhanmondi': [23.7461, 90.3742],
  'uttara': [23.8759, 90.3795],
  'mirpur': [23.8223, 90.3654],
  'tejgaon': [23.7639, 90.3925],
  'badda': [23.7806, 90.4262],
  'motijheel': [23.7330, 90.4172],
  'mohammadpur': [23.7662, 90.3586],
  'rampura': [23.7618, 90.4250],
  'khilgaon': [23.7510, 90.4290],
  'bashundhara': [23.8150, 90.4250],
  'cantonment': [23.8040, 90.4000],
  'shahbagh': [23.7389, 90.3956],
  'malibagh': [23.7503, 90.4128],
  'kawran bazar': [23.7510, 90.3926],
  'lalbagh': [23.7190, 90.3880],
  'nikunja': [23.8300, 90.4150],
};

LatLng? areaPoint(String area) {
  final a = _areas[area.trim().toLowerCase()];
  return a == null ? null : LatLng(a[0], a[1]);
}

/// Real GPS if the donor has it, otherwise the centre of their area.
LatLng? donorPoint(Donor d) {
  if (d.location != null) return LatLng(d.location!.latitude, d.location!.longitude);
  return areaPoint(d.area);
}