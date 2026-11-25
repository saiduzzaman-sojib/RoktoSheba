import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/back_link.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/shimmer.dart';
import 'hospital_service.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  List<Hospital> _all = [];
  String _q = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await HospitalService.currentPosition();
      final list = await HospitalService.nearby(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _all = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(String url) async {
    final ok = await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = _all
        .where((h) => h.name.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return GradientScaffold(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
          children: [
            const BackLink('Back'),
            const SizedBox(height: 10),
            const Text('Nearby Hospitals',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Within 8 km of your location',
                style: TextStyle(color: context.textMuted)),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => _q = v),
              decoration: const InputDecoration(
                hintText: 'Search hospital name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const SkeletonList(count: 4)
            else if (_error != null)
              EmptyState(
                icon: Icons.location_off_rounded,
                title: 'Could not load hospitals',
                message: _error!,
                actionLabel: 'Try again',
                onAction: _load,
              )
            else if (shown.isEmpty)
              const EmptyState(
                icon: Icons.local_hospital_outlined,
                title: 'No hospitals found',
                message: 'Try a different name or move to a bigger area.',
              )
            else
              for (final h in shown) ...[
                _HospitalCard(
                  h: h,
                  onCall: h.phone == null
                      ? null
                      : () => _open(
                          'tel:${h.phone!.replaceAll(RegExp(r'[^0-9+]'), '')}'),
                  onDirections: () => _open(
                      'https://www.google.com/maps/dir/?api=1&destination=${h.lat},${h.lon}'),
                ),
                const SizedBox(height: 14),
              ],
            const SizedBox(height: 8),
            Text('Data: © OpenStreetMap contributors',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: context.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Hospital h;
  final VoidCallback? onCall;
  final VoidCallback onDirections;
  const _HospitalCard(
      {required this.h, required this.onCall, required this.onDirections});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: AppColors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                        '${h.distanceKm.toStringAsFixed(1)} km away'
                        '${h.address != null ? ' · ${h.address}' : ''}',
                        style: TextStyle(
                            fontSize: 12.5, color: context.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (onCall != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Call'),
                  ),
                ),
              if (onCall != null) const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDirections,
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.red),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Directions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}