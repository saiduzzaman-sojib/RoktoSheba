import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/blood_drop.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/language_tile.dart';
import '../data/auth_repository.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _pw = TextEditingController();
  bool _busy = false, _hide = true;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signIn(_id.text, _pw.text);
      // The router redirects to /home automatically.
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(tr(authErrorMessage(e)))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgot() async {
    final messenger = ScaffoldMessenger.of(context);
    final id = _id.text.trim();
    if (!id.contains('@')) {
      messenger.showSnackBar(SnackBar(
          content: Text(tr(
              'Password reset by email only works for accounts created with an email.'))));
      return;
    }
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(id);
      messenger.showSnackBar(
          SnackBar(content: Text(tr('Password reset email sent.'))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(tr(authErrorMessage(e)))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [BloodDrop(size: 36), LanguageChips()],
                ),
                const SizedBox(height: 28),
                Text(tr('Welcome back'),
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.6)),
                const SizedBox(height: 6),
                FieldLabel(tr('Log in to find donors or accept requests.')),
                const SizedBox(height: 22),
                FieldLabel(tr('Mobile or email')),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _id,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(hintText: '01XXXXXXXXX'),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return tr('Enter your mobile or email');
                    if (!t.contains('@') && !isValidMobile(t)) {
                      return tr('Enter a valid mobile number (01XXXXXXXXX)');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                FieldLabel(tr('Password')),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pw,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    hintText: tr('Password'),
                    suffixIcon: IconButton(
                      icon: Icon(_hide ? Icons.visibility_off : Icons.visibility,
                          color: context.textMuted),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                  validator: (v) =>
                      (v ?? '').isEmpty ? tr('Enter your password') : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgot,
                    child: Text(tr('Forgot password?'),
                        style: TextStyle(
                            color: context.accent, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 4),
                AppButton(label: tr('Log in'), loading: _busy, onPressed: _submit),
                const SizedBox(height: 18),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/register'),
                    child: Text.rich(TextSpan(
                      style: TextStyle(fontSize: 13, color: context.textMuted),
                      children: [
                        TextSpan(text: tr('New here? ')),
                        TextSpan(
                            text: tr('Register as a donor'),
                            style: TextStyle(
                                color: context.accent,
                                fontWeight: FontWeight.w800)),
                      ],
                    )),
                  ),
                ),
                const SizedBox(height: 22),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/camps'),
                    child: Text(tr('Continue as visitor'),
                        style: TextStyle(fontSize: 13, color: context.textMuted)),
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