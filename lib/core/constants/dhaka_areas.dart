import 'package:latlong2/latlong.dart';
import '../../features/donors/models/donor.dart';

/// name -> [lat, lng]. Add more areas here any time.
const dhakaAreas = <String, List<double>>{
  'Farmgate': [23.7588, 90.3892],
  'Mohakhali': [23.7781, 90.4048],
  'Mohakhali DOHS': [23.7810, 90.3990],
  'Nabisco': [23.7806, 90.3965],
  'Gulshan': [23.7925, 90.4078],
  'Gulistan': [23.7236, 90.4122],
  'Banani': [23.7937, 90.4066],
  'Dhanmondi': [23.7461, 90.3742],
  'Uttara': [23.8759, 90.3795],
  'Mirpur': [23.8223, 90.3654],
  'Tejgaon': [23.7639, 90.3925],
  'Badda': [23.7806, 90.4262],
  'Motijheel': [23.7330, 90.4172],
  'Mohammadpur': [23.7662, 90.3586],
  'Rampura': [23.7618, 90.4250],
  'Khilgaon': [23.7510, 90.4290],
  'Bashundhara': [23.8150, 90.4250],
  'Cantonment': [23.8040, 90.4000],
  'Shahbagh': [23.7389, 90.3956],
  'Malibagh': [23.7503, 90.4128],
  'Kawran Bazar': [23.7510, 90.3926],
  'Lalbagh': [23.7190, 90.3880],
  'Nikunja': [23.8300, 90.4150],
  'Agargaon': [23.7775, 90.3800],
  'Shyamoli': [23.7745, 90.3655],
  'Paltan': [23.7330, 90.4125],
  'Jatrabari': [23.7100, 90.4350],
  'Old Dhaka': [23.7104, 90.4074],
  'Sadarghat': [23.7060, 90.4070],
  'Azimpur': [23.7280, 90.3850],
  'New Market': [23.7340, 90.3850],
  'Wari': [23.7185, 90.4170],
  'Mugda': [23.7300, 90.4300],
  'Pallabi': [23.8280, 90.3650],
  'Kafrul': [23.7950, 90.3800],
  'Tongi': [23.8900, 90.4040],
  'Savar': [23.8583, 90.2667],
  'Demra': [23.7140, 90.4780],
  'Keraniganj': [23.7000, 90.3500],
};

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

/// Names starting with (or containing) what the user typed.
List<String> areaSuggestions(String q) {
  final n = _norm(q);
  if (n.isEmpty) return const [];
  final starts = <String>[], contains = <String>[];
  for (final k in dhakaAreas.keys) {
    final kn = _norm(k);
    if (kn.startsWith(n)) {
      starts.add(k);
    } else if (kn.contains(n)) {
      contains.add(k);
    }
  }
  return [...starts, ...contains].take(6).toList();
}

LatLng? areaPoint(String area) {
  final n = _norm(area);
  if (n.isEmpty) return null;
  for (final e in dhakaAreas.entries) {
    if (_norm(e.key) == n) return LatLng(e.value[0], e.value[1]);
  }
  for (final e in dhakaAreas.entries) {
    final kn = _norm(e.key);
    if (kn.contains(n) || n.contains(kn)) return LatLng(e.value[0], e.value[1]);
  }
  return null;
}

/// Real GPS if the donor has it, otherwise the centre of their area.
LatLng? donorPoint(Donor d) {
  if (d.location != null) return LatLng(d.location!.latitude, d.location!.longitude);
  return areaPoint(d.area);
}