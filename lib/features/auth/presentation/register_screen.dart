import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/blood.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/photo.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/area_field.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/blood_chip.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../data/auth_repository.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _pw = TextEditingController();
  final _district = TextEditingController(text: 'Dhaka');
  final _area = TextEditingController();

  String _group = 'B+';
  String? _photoB64;
  Uint8List? _photoBytes;
  DateTime? _last;
  bool _busy = false, _hide = true;

  @override
  void dispose() {
    for (final c in [_name, _mobile, _pw, _district, _area]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final b64 = await pickPhotoB64();
      if (b64 == null || !mounted) return;
      setState(() {
        _photoB64 = b64;
        _photoBytes = base64Decode(b64);
      });
    } catch (_) {
      messenger.showSnackBar(SnackBar(
          content: Text(tr('Could not open photos. Check permission.'))));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _last ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (d != null) setState(() => _last = d);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    if (_area.text.trim().isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(tr('Enter your area.'))));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).register(
            name: _name.text.trim(),
            mobile: _mobile.text,
            password: _pw.text,
            bloodGroup: _group,
            district: _district.text.trim(),
            area: _area.text.trim(),
            lastDonation: _last,
            photoB64: _photoB64,
          );
      // The router redirects to /home automatically.
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(tr(authErrorMessage(e)))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _photoBytes != null
                              ? Avatar(bytes: _photoBytes, name: _name.text, size: 88, radius: 28)
                              : Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    color: context.surface,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                        color: AppColors.red.withValues(alpha: .5),
                                        width: 2),
                                  ),
                                  child: Icon(Icons.photo_camera_outlined,
                                      color: context.accent, size: 30),
                                ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                  color: context.isDark ? AppColors.red : AppColors.ink,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: context.bgBase, width: 3)),
                              child: const Icon(Icons.add, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('Join as a donor'),
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.5)),
                          const SizedBox(height: 4),
                          FieldLabel(tr('Add a photo so people can recognise you')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: tr('Full name')),
                  validator: (v) =>
                      (v ?? '').trim().length < 2 ? tr('Enter your full name') : null,
                ),
                const SizedBox(height: 16),
                FieldLabel(tr('Blood group')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final g in bloodGroups)
                      BloodChip(
                          label: g,
                          selected: _group == g,
                          onTap: () => setState(() => _group = g)),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobile,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(hintText: tr('Mobile 01XXXXXXXXX')),
                  validator: (v) => isValidMobile(v ?? '')
                      ? null
                      : tr('Enter a valid mobile number (01XXXXXXXXX)'),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _district,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(hintText: tr('District')),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? tr('Required') : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: AreaField(controller: _area)),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: context.line),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _last == null
                                ? tr('Last donation date (optional)')
                                : trp('Last donation: {date}', {'date': fmtDate(_last!)}),
                            style: TextStyle(
                                fontSize: 15,
                                color: _last == null ? context.textMuted : context.textMain),
                          ),
                        ),
                        if (_last != null)
                          GestureDetector(
                            onTap: () => setState(() => _last = null),
                            child: Icon(Icons.close, size: 18, color: context.textMuted),
                          )
                        else
                          Icon(Icons.calendar_today_outlined,
                              size: 18, color: context.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _pw,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    hintText: tr('Password (8+, letters and numbers)'),
                    suffixIcon: IconButton(
                      icon: Icon(_hide ? Icons.visibility_off : Icons.visibility,
                          color: context.textMuted),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                  validator: (v) {
                    final p = v ?? '';
                    if (p.length < 8) return tr('Use at least 8 characters');
                    if (!RegExp(r'[A-Za-z]').hasMatch(p) ||
                        !RegExp(r'\d').hasMatch(p)) {
                      return tr('Use letters and numbers');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                AppButton(label: tr('Create account'), loading: _busy, onPressed: _submit),
                const SizedBox(height: 18),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text.rich(TextSpan(
                      style: TextStyle(fontSize: 13, color: context.textMuted),
                      children: [
                        TextSpan(text: tr('Have an account? ')),
                        TextSpan(
                            text: tr('Log in'),
                            style: TextStyle(
                                color: context.accent, fontWeight: FontWeight.w800)),
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}