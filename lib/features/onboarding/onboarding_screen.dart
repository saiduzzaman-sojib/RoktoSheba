import 'package:flutter/material.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/language_tile.dart';

class _Slide {
  final IconData icon;
  final String title, body;
  const _Slide(this.icon, this.title, this.body);
}

const _slides = <_Slide>[
  _Slide(
    Icons.bloodtype_rounded,
    'Find blood fast',
    'Search eligible donors near you by blood group and distance, in minutes.',
  ),
  _Slide(
    Icons.lock_rounded,
    'Your phone stays private',
    'Your number is shared only if you accept a request, and only with that requester.',
  ),
  _Slide(
    Icons.favorite_rounded,
    'Be a lifesaver',
    'Turn on availability, get alerts for nearby requests, and track your donation record.',
  ),
];

/// Shown once, pushed from the splash screen. Pops with `true` when finished.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  bool get _last => _page == _slides.length - 1;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _finish() => Navigator.of(context).pop(true);

  void _next() {
    if (_last) {
      _finish();
    } else {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LanguageChips(),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _last ? 0 : 1,
                    child: TextButton(
                      onPressed: _last ? null : _finish,
                      child: Text(tr('Skip'),
                          style: TextStyle(
                              color: context.textMuted, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _SlideView(_slides[i]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? context.accent : context.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                  label: _last ? tr('Get started') : tr('Next'), onPressed: _next),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide s;
  const _SlideView(this.s);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            gradient: AppColors.redGradient,
            borderRadius: BorderRadius.circular(48),
            boxShadow: [
              BoxShadow(
                color: AppColors.red.withValues(alpha: .35),
                blurRadius: 40,
                offset: const Offset(0, 18),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Icon(s.icon, size: 72, color: Colors.white),
        ),
        const SizedBox(height: 44),
        Text(tr(s.title),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(tr(s.body),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.55, color: context.textMuted)),
        ),
      ],
    );
  }
}