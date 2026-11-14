import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/blood.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/back_link.dart';
import '../../core/widgets/blood_chip.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../blog/blog_post.dart';
import '../blog/blog_provider.dart';
import '../camps/camp.dart';
import '../camps/camp_provider.dart';
import '../donors/models/donor.dart';
import '../requests/presentation/request_widgets.dart';
import 'admin_provider.dart';

// ------------------------------------------------------------------ helpers

List<Widget> _spaced(List<Widget> items, [double gap = 14]) => [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) SizedBox(height: gap),
        items[i],
      ],
    ];

Future<bool> _confirm(BuildContext context, String title, String yes) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: Text(yes)),
      ],
    ),
  );
  return r == true;
}

void _openSheet(BuildContext context, Widget child) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => child,
    );

class _SheetBody extends StatelessWidget {
  final List<Widget> children;
  const _SheetBody(this.children);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            22, 24, 22, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      );
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          FieldLabel(label),
        ]),
      );
}

Widget _pair(Widget a, Widget b) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: a),
      const SizedBox(width: 12),
      Expanded(child: b),
    ]);

// ------------------------------------------------------------------- screen

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});
  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  static const _tabs = ['Reports', 'Donors', 'Camps', 'Articles', 'Rules'];
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(isAdminProvider);
    if (admin.isLoading && !admin.hasValue) {
      return const AppPage(navPadding: false, children: [
        SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator(color: AppColors.red))),
      ]);
    }
    if (admin.value != true) {
      return const AppPage(navPadding: false, children: [
        BackLink('Back'),
        Text('Admin panel', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        FieldLabel('This area is only for admins.'),
      ]);
    }

    final Widget content = switch (_tab) {
      0 => const _ReportsTab(),
      1 => const _DonorsTab(),
      2 => const _CampsTab(),
      3 => const _BlogTab(),
      _ => const _RulesTab(),
    };

    return AppPage(navPadding: false, children: [
      const BackLink('Back'),
      const Text('Admin panel',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (var i = 0; i < _tabs.length; i++) ...[
            BloodChip(label: _tabs[i], selected: _tab == i, onTap: () => setState(() => _tab = i)),
            const SizedBox(width: 8),
          ],
        ]),
      ),
      content,
    ]);
  }
}

// ------------------------------------------------------------------ reports

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donors = ref.watch(allDonorsProvider).value ?? const <Donor>[];
    final s = ref.watch(adminStatsProvider).value;
    String n(int? v) => v == null ? '...' : '$v';

    final byGroup = {
      for (final g in bloodGroups) g: donors.where((d) => d.bloodGroup == g).length
    };
    final maxV = byGroup.values.fold<int>(1, (a, b) => b > a ? b : a);

    return Column(
      children: _spaced([
        _pair(_Stat('Registered donors', '${donors.length}'),
            _Stat('Verified', '${donors.where((d) => d.verified).length}')),
        _pair(_Stat('Available now', '${donors.where((d) => d.canBeContacted).length}'),
            _Stat('Blocked', '${donors.where((d) => d.blocked).length}')),
        _pair(_Stat('Requests posted', n(s?.requests)), _Stat('Open requests', n(s?.openRequests))),
        _pair(_Stat('Fulfilled', n(s?.fulfilled)), _Stat('Donations logged', n(s?.donations))),
        const Text('Donors by blood group',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        AppCard(
          child: Column(children: [
            for (final g in bloodGroups)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  SizedBox(
                      width: 40,
                      child: Text(g, style: const TextStyle(fontWeight: FontWeight.w800))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: byGroup[g]! / maxV,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                      width: 28,
                      child: Text('${byGroup[g]}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                ]),
              ),
          ]),
        ),
        Center(
          child: TextButton(
            onPressed: () => ref.invalidate(adminStatsProvider),
            child: const Text('Refresh numbers',
                style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------------- donors

class _DonorsTab extends ConsumerStatefulWidget {
  const _DonorsTab();
  @override
  ConsumerState<_DonorsTab> createState() => _DonorsTabState();
}

class _DonorsTabState extends ConsumerState<_DonorsTab> {
  final _search = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allDonorsProvider).value ?? const <Donor>[];
    final q = _search.text.trim().toLowerCase();
    final list = all.where((d) {
      if (_filter == 'Unverified' && d.verified) return false;
      if (_filter == 'Blocked' && !d.blocked) return false;
      if (q.isEmpty) return true;
      return d.name.toLowerCase().contains(q) ||
          d.area.toLowerCase().contains(q) ||
          d.district.toLowerCase().contains(q) ||
          d.bloodGroup.toLowerCase() == q;
    }).toList();
    final shown = list.take(60).toList();

    return Column(
      children: _spaced([
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(hintText: 'Search name, area or blood group'),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final f in ['All', 'Unverified', 'Blocked']) ...[
              BloodChip(label: f, selected: _filter == f, onTap: () => setState(() => _filter = f)),
              const SizedBox(width: 8),
            ],
          ]),
        ),
        FieldLabel(list.length > shown.length
            ? 'Showing ${shown.length} of ${list.length}. Refine your search to see others.'
            : '${list.length} donor${list.length == 1 ? '' : 's'}'),
        for (final d in shown)
          AppCard(
            onTap: () => _openSheet(context, _DonorSheet(donor: d)),
            child: Row(children: [
              Avatar(bytes: d.photoBytes, name: d.name, size: 46, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: '${d.name} ',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    TextSpan(
                        text: d.bloodGroup,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.red)),
                  ])),
                  FieldLabel('${d.area}, ${d.district}'),
                ]),
              ),
              if (d.blocked)
                const Text('Blocked',
                    style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800))
              else if (d.verified)
                const Text('Verified ✓',
                    style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)),
            ]),
          ),
      ]),
    );
  }
}

class _DonorSheet extends ConsumerWidget {
  final Donor donor;
  const _DonorSheet({required this.donor});

  Future<void> _run(BuildContext context, Future<void> Function() action, String done) async {
    final m = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await action();
      nav.pop();
      m.showSnackBar(SnackBar(content: Text(done)));
    } catch (_) {
      m.showSnackBar(const SnackBar(
          content: Text('Could not save. Check your internet and admin role.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(adminRepositoryProvider);
    final d = donor;
    return _SheetBody([
      Row(children: [
        Avatar(bytes: d.photoBytes, name: d.name, size: 64, radius: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${d.name} · ${d.bloodGroup}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            FieldLabel('${d.area}, ${d.district}'),
          ]),
        ),
      ]),
      const SizedBox(height: 16),
      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection(FS.donorPrivate).doc(d.uid).get(),
        builder: (context, snap) {
          final phone = snap.data?.data()?['mobile'] as String?;
          return Row(children: [
            Expanded(
              child: Text(
                  phone ?? (snap.connectionState == ConnectionState.done ? 'No number' : 'Loading...'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            if (phone != null && phone.isNotEmpty) ContactButtons(phone),
          ]);
        },
      ),
      const SizedBox(height: 8),
      FieldLabel(
          'Last donation: ${d.lastDonation == null ? 'not shared' : DateFormat('d MMM yyyy').format(d.lastDonation!)}'),
      FieldLabel(
          'Status: ${d.blocked ? 'Blocked' : d.canBeContacted ? 'Available' : 'Not available'}${d.verified ? ' · Verified' : ''}'),
      const SizedBox(height: 18),
      AppButton(
        label: d.verified ? 'Remove verification' : 'Verify donor',
        onPressed: () => _run(context, () => repo.setVerified(d.uid, !d.verified),
            d.verified ? 'Verification removed' : 'Donor verified'),
      ),
      Center(
        child: TextButton(
          onPressed: () async {
            if (!d.blocked &&
                !await _confirm(context, 'Block ${d.name}? Their open requests will be cancelled.', 'Block')) {
              return;
            }
            if (!context.mounted) return;
            await _run(context, () => repo.setBlocked(d.uid, !d.blocked),
                d.blocked ? 'Donor unblocked' : 'Donor blocked');
          },
          child: Text(d.blocked ? 'Unblock donor' : 'Block donor',
              style: TextStyle(
                  color: d.blocked ? AppColors.green : AppColors.red,
                  fontWeight: FontWeight.w800)),
        ),
      ),
    ]);
  }
}

// -------------------------------------------------------------------- camps

class _CampsTab extends ConsumerWidget {
  const _CampsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camps = ref.watch(campsProvider).value ?? const <Camp>[];
    return Column(
      children: _spaced([
        AppButton(label: 'Add a camp', onPressed: () => _openSheet(context, const _CampForm())),
        if (camps.isEmpty) const FieldLabel('No camps yet.'),
        for (final c in camps)
          AppCard(
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  FieldLabel('${DateFormat('d MMM yyyy, h:mm a').format(c.date)} · ${c.place}'),
                ]),
              ),
              TextButton(
                onPressed: () => _openSheet(context, _CampForm(camp: c)),
                child: const Text('Edit',
                    style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)),
              ),
              TextButton(
                onPressed: () async {
                  final m = ScaffoldMessenger.of(context);
                  if (!await _confirm(context, 'Delete "${c.title}"?', 'Delete')) return;
                  try {
                    await ref.read(adminRepositoryProvider).deleteCamp(c.id);
                  } catch (_) {
                    m.showSnackBar(const SnackBar(content: Text('Could not delete.')));
                  }
                },
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _CampForm extends ConsumerStatefulWidget {
  final Camp? camp;
  const _CampForm({this.camp});
  @override
  ConsumerState<_CampForm> createState() => _CampFormState();
}

class _CampFormState extends ConsumerState<_CampForm> {
  late final _title = TextEditingController(text: widget.camp?.title);
  late final _place = TextEditingController(text: widget.camp?.place);
  late final _organizer = TextEditingController(text: widget.camp?.organizer);
  late final _district = TextEditingController(text: widget.camp?.district ?? 'Dhaka');
  late final _desc = TextEditingController(text: widget.camp?.description);
  late final _lat =
      TextEditingController(text: widget.camp?.location?.latitude.toString() ?? '');
  late final _lng =
      TextEditingController(text: widget.camp?.location?.longitude.toString() ?? '');
  late DateTime _date = widget.camp?.date ??
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 10);
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_title, _place, _organizer, _district, _desc, _lat, _lng]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: _date.hour, minute: _date.minute));
    if (!mounted) return;
    setState(() => _date = DateTime(d.year, d.month, d.day, t?.hour ?? _date.hour, t?.minute ?? _date.minute));
  }

  Future<void> _useMyLocation() async {
    final r = await getMyLocation();
    if (!mounted) return;
    if (r.point == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not get your location.')));
      return;
    }
    setState(() {
      _lat.text = r.point!.latitude.toStringAsFixed(5);
      _lng.text = r.point!.longitude.toStringAsFixed(5);
    });
  }

  Future<void> _save() async {
    final m = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final title = _title.text.trim(), place = _place.text.trim();
    if (title.isEmpty || place.isEmpty) {
      m.showSnackBar(const SnackBar(content: Text('Title and place are required.')));
      return;
    }
    GeoPoint? gp;
    final latT = _lat.text.trim(), lngT = _lng.text.trim();
    if (latT.isNotEmpty || lngT.isNotEmpty) {
      final lat = double.tryParse(latT), lng = double.tryParse(lngT);
      if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) {
        m.showSnackBar(const SnackBar(
            content: Text('Enter valid coordinates, or leave both empty.')));
        return;
      }
      gp = GeoPoint(lat, lng);
    }
    setState(() => _busy = true);
    try {
      await ref.read(adminRepositoryProvider).saveCamp(widget.camp?.id, {
        'title': title,
        'place': place,
        'organizer': _organizer.text.trim(),
        'district': _district.text.trim(),
        'description': _desc.text.trim(),
        'date': Timestamp.fromDate(_date),
        'location': gp,
      });
      nav.pop();
      m.showSnackBar(const SnackBar(content: Text('Camp saved')));
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Could not save. Are you an admin?')));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget field(TextEditingController c, String hint,
            {int lines = 1, TextInputType? type}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: c,
            minLines: lines,
            maxLines: lines,
            keyboardType: type,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: hint),
          ),
        );

    return _SheetBody([
      Text(widget.camp == null ? 'Add a camp' : 'Edit camp',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),
      field(_title, 'Title'),
      field(_place, 'Place'),
      field(_organizer, 'Organizer'),
      field(_district, 'District'),
      field(_desc, 'Description (optional)', lines: 3),
      GestureDetector(
        onTap: _pickDateTime,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.border)),
          child: Text(DateFormat('EEE, d MMM yyyy · h:mm a').format(_date),
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
      Row(children: [
        Expanded(child: field(_lat, 'Latitude', type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
        const SizedBox(width: 10),
        Expanded(child: field(_lng, 'Longitude', type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
      ]),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: _useMyLocation,
          child: const Text('Use my current location',
              style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)),
        ),
      ),
      const FieldLabel('Coordinates are optional. They enable "Near me" and Directions.'),
      const SizedBox(height: 14),
      AppButton(label: 'Save camp', loading: _busy, onPressed: _save),
    ]);
  }
}

// ----------------------------------------------------------------- articles

class _BlogTab extends ConsumerWidget {
  const _BlogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(blogPostsProvider).value ?? const <BlogPost>[];
    return Column(
      children: _spaced([
        AppButton(label: 'Add an article', onPressed: () => _openSheet(context, const _BlogForm())),
        if (posts.isEmpty) const FieldLabel('No articles yet.'),
        for (final p in posts)
          AppCard(
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  FieldLabel('${p.category} · ${DateFormat('d MMM yyyy').format(p.date)}'),
                ]),
              ),
              TextButton(
                onPressed: () => _openSheet(context, _BlogForm(post: p)),
                child: const Text('Edit',
                    style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)),
              ),
              TextButton(
                onPressed: () async {
                  final m = ScaffoldMessenger.of(context);
                  if (!await _confirm(context, 'Delete "${p.title}"?', 'Delete')) return;
                  try {
                    await ref.read(adminRepositoryProvider).deleteBlog(p.id);
                  } catch (_) {
                    m.showSnackBar(const SnackBar(content: Text('Could not delete.')));
                  }
                },
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _BlogForm extends ConsumerStatefulWidget {
  final BlogPost? post;
  const _BlogForm({this.post});
  @override
  ConsumerState<_BlogForm> createState() => _BlogFormState();
}

class _BlogFormState extends ConsumerState<_BlogForm> {
  late final _title = TextEditingController(text: widget.post?.title);
  late final _content = TextEditingController(text: widget.post?.content);
  late String _cat = widget.post?.category ?? 'Tip';
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final m = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final title = _title.text.trim(), content = _content.text.trim();
    if (title.isEmpty || content.isEmpty) {
      m.showSnackBar(const SnackBar(content: Text('Title and text are required.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(adminRepositoryProvider).saveBlog(widget.post?.id, {
        'title': title,
        'content': content,
        'category': _cat,
        'author': widget.post?.author ?? 'Roktosheba Team',
        'date': Timestamp.fromDate(widget.post?.date ?? DateTime.now()),
      });
      nav.pop();
      m.showSnackBar(const SnackBar(content: Text('Article saved')));
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Could not save. Are you an admin?')));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetBody([
      Text(widget.post == null ? 'Add an article' : 'Edit article',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),
      Wrap(spacing: 8, children: [
        for (final c in ['Tip', 'Myth', 'Story'])
          BloodChip(label: c, selected: _cat == c, onTap: () => setState(() => _cat = c)),
      ]),
      const SizedBox(height: 14),
      TextField(
          controller: _title,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Title')),
      const SizedBox(height: 12),
      TextField(
          controller: _content,
          minLines: 8,
          maxLines: 14,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Text (leave a blank line between paragraphs)')),
      const SizedBox(height: 16),
      AppButton(label: 'Save article', loading: _busy, onPressed: _save),
    ]);
  }
}

// -------------------------------------------------------------------- rules

class _RulesTab extends ConsumerStatefulWidget {
  const _RulesTab();
  @override
  ConsumerState<_RulesTab> createState() => _RulesTabState();
}

class _RulesTabState extends ConsumerState<_RulesTab> {
  final _minAge = TextEditingController();
  final _maxAge = TextEditingController();
  final _weight = TextEditingController();
  final _gap = TextEditingController();
  bool _loaded = false, _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_minAge, _maxAge, _weight, _gap]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(EligibilityRulesView r) {
    _minAge.text = '${r.minAge}';
    _maxAge.text = '${r.maxAge}';
    _weight.text = r.minWeight == r.minWeight.roundToDouble()
        ? '${r.minWeight.toInt()}'
        : '${r.minWeight}';
    _gap.text = '${r.gapDays}';
  }

  Future<void> _load() async {
    EligibilityRulesView r = const EligibilityRulesView(18, 60, 50, 90);
    try {
      final d = await FirebaseFirestore.instance.collection(FS.config).doc('eligibility').get();
      final m = d.data();
      if (m != null) {
        r = EligibilityRulesView(
          ((m['minAge'] ?? 18) as num).toInt(),
          ((m['maxAge'] ?? 60) as num).toInt(),
          ((m['minWeight'] ?? 50) as num).toDouble(),
          ((m['gapDays'] ?? 90) as num).toInt(),
        );
      }
    } catch (_) {}
    if (!mounted) return;
    _fill(r);
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final m = ScaffoldMessenger.of(context);
    final minAge = int.tryParse(_minAge.text.trim());
    final maxAge = int.tryParse(_maxAge.text.trim());
    final weight = double.tryParse(_weight.text.trim());
    final gap = int.tryParse(_gap.text.trim());
    if (minAge == null || maxAge == null || weight == null || gap == null) {
      m.showSnackBar(const SnackBar(content: Text('Fill in all four numbers.')));
      return;
    }
    if (minAge < 16 || maxAge > 80 || minAge >= maxAge) {
      m.showSnackBar(const SnackBar(content: Text('Age must be between 16 and 80, minimum below maximum.')));
      return;
    }
    if (weight < 30 || weight > 120 || gap < 1 || gap > 365) {
      m.showSnackBar(const SnackBar(content: Text('Weight 30-120 kg and gap 1-365 days.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(adminRepositoryProvider).saveRules({
        'minAge': minAge,
        'maxAge': maxAge,
        'minWeight': weight,
        'gapDays': gap,
      });
      m.showSnackBar(const SnackBar(content: Text('Rules saved')));
    } catch (_) {
      m.showSnackBar(const SnackBar(content: Text('Could not save. Are you an admin?')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox(
          height: 160, child: Center(child: CircularProgressIndicator(color: AppColors.red)));
    }
    Widget num(TextEditingController c, String hint) => TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(hintText: hint),
        );
    return Column(
      children: _spaced([
        const FieldLabel('These rules drive the eligibility checker and the waiting period after a donation.'),
        _pair(num(_minAge, 'Minimum age'), num(_maxAge, 'Maximum age')),
        _pair(num(_weight, 'Minimum weight (kg)'), num(_gap, 'Gap between donations (days)')),
        AppButton(label: 'Save rules', loading: _busy, onPressed: _save),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _fill(const EligibilityRulesView(18, 60, 50, 90))),
            child: const Text('Reset form to defaults',
                style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}

class EligibilityRulesView {
  final int minAge, maxAge, gapDays;
  final double minWeight;
  const EligibilityRulesView(this.minAge, this.maxAge, this.minWeight, this.gapDays);
}