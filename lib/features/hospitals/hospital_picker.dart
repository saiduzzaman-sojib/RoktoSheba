import 'package:flutter/material.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/shimmer.dart';
import 'hospital_service.dart';

/// Button for the request form. Fills [controller] with the chosen hospital name.
class HospitalPickerButton extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<Hospital>? onPicked;
  const HospitalPickerButton({super.key, required this.controller, this.onPicked});

  Future<void> _open(BuildContext context) async {
    final h = await showModalBottomSheet<Hospital>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => const _PickerSheet(),
    );
    if (h != null) {
      controller.text = h.name;
      onPicked?.call(h);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _open(context),
        icon: Icon(Icons.local_hospital_outlined, size: 18, color: context.accent),
        label: Text(tr('Pick from nearby hospitals'),
            style: TextStyle(color: context.accent, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet();
  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
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
    try {
      final pos = await HospitalService.currentPosition();
      final list = await HospitalService.nearby(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _all = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = tr(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = _all
        .where((h) => h.name.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    final height = MediaQuery.of(context).size.height * .75;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Choose a hospital'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: tr('Search hospital name'),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const SingleChildScrollView(child: SkeletonList(count: 4))
                    : _error != null
                        ? Center(
                            child: Text(_error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: context.textMuted)))
                        : shown.isEmpty
                            ? Center(
                                child: Text(tr('No hospitals found'),
                                    style: TextStyle(color: context.textMuted)))
                            : ListView.separated(
                                itemCount: shown.length,
                                separatorBuilder: (_, _) =>
                                    Divider(height: 1, color: context.line),
                                itemBuilder: (_, i) {
                                  final h = shown[i];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.local_hospital_rounded,
                                        color: AppColors.red),
                                    title: Text(h.name,
                                        style: const TextStyle(fontWeight: FontWeight.w700)),
                                    subtitle: Text(
                                        trp('{n} km away',
                                            {'n': h.distanceKm.toStringAsFixed(1)}),
                                        style: TextStyle(color: context.textMuted)),
                                    onTap: () => Navigator.pop(context, h),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}