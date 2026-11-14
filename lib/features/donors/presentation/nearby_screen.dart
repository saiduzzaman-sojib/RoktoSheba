import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/blood.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/distance.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/blood_chip.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/donor.dart';
import '../providers/donor_provider.dart';

class _Item {
  final Donor donor;
  final double km;
  _Item(this.donor, this.km);
}

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});
  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  final _map = MapController();
  String _group = 'All';
  double _radius = 5;
  Donor? _selected;

  static const _radii = [2.5, 5.0, 10.0, 25.0];

  double _zoom(double r) => r <= 2.5 ? 14 : r <= 5 ? 13 : r <= 10 ? 12 : 11;

  String _radiusLabel(double r) => r == r.roundToDouble() ? '${r.toInt()} km' : '$r km';

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Widget _message(String title, String body, String button, VoidCallback onTap) {
    return AppPage(children: [
      const Text('Donors near you',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            FieldLabel(body),
            const SizedBox(height: 14),
            AppButton(label: button, onPressed: onTap),
          ],
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(myLocationProvider);

    if (loc.isLoading) {
      return const AppPage(children: [
        SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator(color: AppColors.red))),
      ]);
    }
    final res = loc.value ?? const LocResult(LocStatus.error);
    if (res.point == null) {
      void retry() => ref.invalidate(myLocationProvider);
      switch (res.status) {
        case LocStatus.serviceOff:
          return _message('Location is off', 'Turn on location services to find donors near you.',
              'Open location settings', () => Geolocator.openLocationSettings());
        case LocStatus.deniedForever:
          return _message('Location permission blocked',
              'Allow location for Roktosheba in your phone settings.',
              'Open app settings', () => Geolocator.openAppSettings());
        case LocStatus.denied:
          return _message('Location permission needed',
              'We need your location to show donors close to you.', 'Allow location', retry);
        default:
          return _message('Could not get your location',
              'Check GPS and internet, then try again.', 'Try again', retry);
      }
    }

    final me = LatLng(res.point!.latitude, res.point!.longitude);
    final myUid = ref.watch(authStateProvider).value?.uid;
    final all = ref.watch(availableDonorsProvider).value ?? const <Donor>[];

    final items = <_Item>[];
    for (final d in all) {
      if (d.uid == myUid || d.location == null || !d.canBeContacted) continue;
      if (_group != 'All' && d.bloodGroup != _group) continue;
      final km = distanceKm(me.latitude, me.longitude, d.location!.latitude, d.location!.longitude);
      if (km <= _radius) items.add(_Item(d, km));
    }
    items.sort((a, b) => a.km.compareTo(b.km));
    final selected = _selected == null ? null : items.where((i) => i.donor.uid == _selected!.uid).firstOrNull;

    return AppPage(children: [
      const Text('Donors near you',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final g in ['All', ...bloodGroups]) ...[
            BloodChip(label: g, selected: _group == g, onTap: () => setState(() => _group = g)),
            const SizedBox(width: 8),
          ],
        ]),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          const Padding(
              padding: EdgeInsets.only(right: 10), child: FieldLabel('Within')),
          for (final r in _radii) ...[
            BloodChip(
                label: _radiusLabel(r),
                selected: _radius == r,
                onTap: () {
                  setState(() => _radius = r);
                  _map.move(me, _zoom(r));
                }),
            const SizedBox(width: 8),
          ],
        ]),
      ),
      SizedBox(
        height: 330,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: me,
                initialZoom: _zoom(_radius),
                interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                onTap: (_, _) => setState(() => _selected = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.saiduzzaman.roktosheba',
                ),
                CircleLayer(circles: [
                  CircleMarker(
                    point: me,
                    radius: _radius * 1000,
                    useRadiusInMeter: true,
                    color: AppColors.red.withValues(alpha: .08),
                    borderColor: AppColors.red.withValues(alpha: .5),
                    borderStrokeWidth: 2,
                  ),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    point: me,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 22),
                    ),
                  ),
                  for (final i in items)
                    Marker(
                      point: LatLng(i.donor.location!.latitude, i.donor.location!.longitude),
                      width: 52,
                      height: 52,
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = i.donor),
                        child: Stack(clipBehavior: Clip.none, children: [
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3)),
                            child: Avatar(
                                bytes: i.donor.photoBytes,
                                name: i.donor.name,
                                size: 44,
                                radius: 22),
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                  gradient: AppColors.redGradient,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white, width: 1.5)),
                              child: Text(i.donor.bloodGroup,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ]),
                      ),
                    ),
                ]),
                RichAttributionWidget(
                  alignment: AttributionAlignment.bottomLeft,
                  attributions: [TextSourceAttribution('OpenStreetMap contributors')],
                ),
              ],
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: .85),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration:
                          const BoxDecoration(color: Color(0xFF3DDC97), shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Text('Live · within ${_radiusLabel(_radius)}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            if (selected != null)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: GestureDetector(
                  onTap: () => context.push('/donor/${selected.donor.uid}'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      Avatar(bytes: selected.donor.photoBytes, name: selected.donor.name, size: 44, radius: 14),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selected.donor.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                            FieldLabel(
                                '${selected.donor.bloodGroup} · ${selected.km.toStringAsFixed(1)} km · ${selected.donor.area}'),
                          ],
                        ),
                      ),
                      const Text('View',
                          style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ),
      FieldLabel(items.isEmpty
          ? 'No available donors in range yet. Try a bigger radius or another blood group.'
          : '${items.length} donor${items.length == 1 ? '' : 's'} · sorted by distance · tap one to see details'),
      for (final i in items)
        AppCard(
          onTap: () => context.push('/donor/${i.donor.uid}'),
          child: Row(children: [
            Avatar(bytes: i.donor.photoBytes, name: i.donor.name, size: 46, radius: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: '${i.donor.name} ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    TextSpan(
                        text: i.donor.bloodGroup,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.red)),
                  ])),
                  FieldLabel('${i.km.toStringAsFixed(1)} km · ${i.donor.area} · Available${i.donor.verified ? ' · Verified ✓' : ''}'),
                ],
              ),
            ),
            const Text('View',
                style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)),
          ]),
        ),
    ]);
  }
}