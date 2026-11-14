import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/blood.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/blood_chip.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../../donors/models/donor.dart';
import '../models/blood_request.dart';
import '../providers/request_provider.dart';
import 'request_widgets.dart';
import '../../../core/widgets/area_field.dart';

class RequestScreen extends ConsumerStatefulWidget {
  /// Set when opened from a donor's page: {uid, name, group, ts}.
  final Map<String, String>? extra;
  const RequestScreen({super.key, this.extra});
  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  static const _urgencies = ['Critical', 'Within 24h', 'Planned'];

  final _hospital = TextEditingController();
  final _district = TextEditingController();
  final _area = TextEditingController();
  int _tab = 0; // 0 new, 1 for me, 2 mine
  String _group = 'B+';
  int _units = 2;
  String _urgency = 'Critical';
  bool _busy = false, _filled = false;
  Map<String, String>? _target;

  @override
  void initState() {
    super.initState();
    _applyExtra(widget.extra);
  }

  @override
  void didUpdateWidget(covariant RequestScreen old) {
    super.didUpdateWidget(old);
    if (widget.extra != null && widget.extra!['ts'] != old.extra?['ts']) {
      _applyExtra(widget.extra);
    }
  }

  void _applyExtra(Map<String, String>? e) {
    if (e == null) return;
    _target = e;
    _group = e['group'] ?? _group;
    _tab = 0;
  }

  @override
  void dispose() {
    _hospital.dispose();
    _district.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _post(Donor me) async {
    final m = ScaffoldMessenger.of(context);
    if (me.blocked) {
      m.showSnackBar(const SnackBar(
          content: Text('Your account is restricted. You cannot post requests.')));
      return;
    }
    final hospital = _hospital.text.trim();
    final district = _district.text.trim();
    final area = _area.text.trim();
    if (hospital.isEmpty || district.isEmpty) {
      m.showSnackBar(const SnackBar(content: Text('Enter the hospital and district.')));
      return;
    }
    setState(() => _busy = true);
    try {
      // The requester's current position stands in for the hospital's.
      final loc = await getMyLocation();
      double r3(double v) => (v * 1000).round() / 1000;
      final GeoPoint? gp = loc.point != null
          ? GeoPoint(r3(loc.point!.latitude), r3(loc.point!.longitude))
          : me.location;
      final id = await ref.read(requestRepositoryProvider).create(
            uid: me.uid,
            name: me.name,
            bloodGroup: _group,
            hospital: hospital,
            district: district,
            area: area,
            units: _units,
            urgency: _urgency,
            location: gp,
            targetDonorId: _target?['uid'],
          );
      if (!mounted) return;
      _hospital.clear();
      setState(() => _target = null);
      context.push('/request/$id');
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Could not post. Check your internet.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<Widget> _form(Donor me, List<String> groups) => [
        if (_target != null)
          AppCard(
            child: Row(children: [
              Expanded(
                child: Text('Direct request to ${_target!['name']}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              GestureDetector(
                onTap: () => setState(() => _target = null),
                child: const Icon(Icons.close, size: 18, color: AppColors.grey),
              ),
            ]),
          ),
        FieldLabel(_target == null
            ? 'Nearby matching donors are notified instantly.'
            : 'Only this donor will be notified.'),
        const FieldLabel('Blood group needed'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final g in groups)
            BloodChip(label: g, selected: _group == g, onTap: () => setState(() => _group = g)),
        ]),
        const FieldLabel('Hospital'),
        TextField(
            controller: _hospital,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Hospital name')),
        const FieldLabel('District and area'),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: _district,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'District'))),
          const SizedBox(width: 10),
          Expanded(child: AreaField(controller: _area)),
        ]),
        AppCard(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Units needed', style: TextStyle(fontWeight: FontWeight.w800)),
            Row(children: [
              BloodChip(
                  label: '-', onTap: () => setState(() => _units = (_units - 1).clamp(1, 9))),
              const SizedBox(width: 14),
              Text('$_units', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(width: 14),
              BloodChip(
                  label: '+', onTap: () => setState(() => _units = (_units + 1).clamp(1, 9))),
            ]),
          ]),
        ),
        const FieldLabel('Urgency'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final u in _urgencies)
            BloodChip(label: u, selected: _urgency == u, onTap: () => setState(() => _urgency = u)),
        ]),
        const FieldLabel(
            'Donors near your current location are alerted. For the best match, post from the hospital.'),
        AppButton(
            label: 'Post request & alert donors',
            loading: _busy,
            onPressed: () => _post(me)),
      ];

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(myDonorProvider).value;
    final incoming = ref.watch(incomingRequestsProvider);
    final mine = ref.watch(myRequestsProvider).value ?? const <BloodRequest>[];

    if (me == null) {
      return const AppPage(children: [
        SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: AppColors.red))),
      ]);
    }
    if (!_filled) {
      _district.text = me.district;
      _area.text = me.area;
      _filled = true;
    }

    final groups = _target != null
        ? (canDonateTo[_target!['group']] ?? bloodGroups)
        : bloodGroups;
    if (!groups.contains(_group)) _group = groups.first;

    final labels = ['New request', 'For me (${incoming.length})', 'My requests'];

    return AppPage(children: [
      const Text('Request blood',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (var i = 0; i < labels.length; i++) ...[
            BloodChip(label: labels[i], selected: _tab == i, onTap: () => setState(() => _tab = i)),
            const SizedBox(width: 8),
          ],
        ]),
      ),
      if (_tab == 0) ..._form(me, groups),
      if (_tab == 1) ...[
        if (!me.canBeContacted)
          const FieldLabel(
              'You are not available right now, so requests are hidden. Turn on availability from Home.')
        else if (incoming.isEmpty)
          const FieldLabel(
              'No open requests match your blood group near you. You will get a banner when one arrives.'),
        for (final i in incoming) RequestTile(r: i.request, km: i.km),
      ],
      if (_tab == 2) ...[
        if (mine.isEmpty) const FieldLabel('You have not posted any requests yet.'),
        for (final r in mine) RequestTile(r: r, mine: true),
      ],
    ]);
  }
}