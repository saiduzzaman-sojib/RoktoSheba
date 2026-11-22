import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/back_link.dart';
import '../../core/widgets/blood_drop.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'consent.dart';
import 'terms_text.dart';

class TermsScreen extends StatefulWidget {
  /// true = opened from Profile just to read.
  final bool readOnly;
  const TermsScreen({super.key, this.readOnly = false});
  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _agree = false;

  Future<void> _continue() async {
    await acceptTerms();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              children: [
                if (widget.readOnly) const BackLink('Back') else const BloodDrop(size: 30),
                const SizedBox(height: 18),
                const Text('Terms & Privacy',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
                const SizedBox(height: 6),
                const FieldLabel('Please read this short summary. It takes one minute.'),
                const SizedBox(height: 16),
                for (final s in termsSections)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(s.body, style: const TextStyle(fontSize: 14, height: 1.5)),
                      ]),
                    ),
                  ),
                FieldLabel('Version $termsVersion'),
              ],
            ),
          ),
          if (!widget.readOnly)
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .9)),
              child: Column(children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _agree = !_agree),
                  child: Row(children: [
                    Checkbox(
                      value: _agree,
                      activeColor: AppColors.red,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                    ),
                    const Expanded(
                      child: Text('I am 18 or older and I agree to the Terms & Privacy.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                AppButton(label: 'Agree and continue', onPressed: _agree ? _continue : null),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('You need to agree to use Roktosheba.'))),
                  child: const Text('Decline',
                      style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}