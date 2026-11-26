import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n.dart';
import 'app_card.dart';
import 'blood_chip.dart';

class LanguageChips extends ConsumerWidget {
  const LanguageChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      BloodChip(
          label: 'English',
          selected: lang == 'en',
          onTap: () => ref.read(langProvider.notifier).set('en')),
      const SizedBox(width: 8),
      BloodChip(
          label: 'বাংলা',
          selected: lang == 'bn',
          onTap: () => ref.read(langProvider.notifier).set('bn')),
    ]);
  }
}

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('Language'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const LanguageChips(),
        ],
      ),
    );
  }
}