import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/blood_drop.dart';
import '../../../core/widgets/gradient_scaffold.dart';
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
      messenger.showSnackBar(SnackBar(content: Text(authErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgot() async {
    final messenger = ScaffoldMessenger.of(context);
    final id = _id.text.trim();
    if (!id.contains('@')) {
      messenger.showSnackBar(const SnackBar(
          content: Text(
              'Password reset by email only works for accounts created with an email.')));
      return;
    }
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(id);
      messenger.showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(authErrorMessage(e))));
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
                const BloodDrop(size: 36),
                const SizedBox(height: 28),
                const Text('Welcome back',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.6)),
                const SizedBox(height: 6),
                const FieldLabel('Log in to find donors or accept requests.'),
                const SizedBox(height: 22),
                const FieldLabel('Mobile or email'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _id,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(hintText: '01XXXXXXXXX'),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Enter your mobile or email';
                    if (!t.contains('@') && !isValidMobile(t)) {
                      return 'Enter a valid mobile number (01XXXXXXXXX)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                const FieldLabel('Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pw,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_hide ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.grey),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                  validator: (v) =>
                      (v ?? '').isEmpty ? 'Enter your password' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgot,
                    child: const Text('Forgot password?',
                        style: TextStyle(
                            color: AppColors.red, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 4),
                AppButton(label: 'Log in', loading: _busy, onPressed: _submit),
                const SizedBox(height: 18),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text.rich(TextSpan(
                      style: TextStyle(fontSize: 13, color: AppColors.grey),
                      children: [
                        TextSpan(text: 'New here? '),
                        TextSpan(
                            text: 'Register as a donor',
                            style: TextStyle(
                                color: AppColors.red,
                                fontWeight: FontWeight.w800)),
                      ],
                    )),
                  ),
                ),
                const SizedBox(height: 22),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/camps'),
                    child: const Text('Continue as visitor',
                        style: TextStyle(fontSize: 13, color: AppColors.grey)),
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