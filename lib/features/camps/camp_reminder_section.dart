import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'camp.dart';
import 'camp_provider.dart';

/// Shows camps with a reminder that happen today or tomorrow.
class CampReminderSection extends ConsumerWidget {
  const CampReminderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(campRemindersProvider);
    final camps = ref.watch(campsProvider).value ?? const <Camp>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final soon = camps.where((c) {
      if (!reminders.contains(c.id)) return false;
      final day = DateTime(c.date.year, c.date.month, c.date.day);
      final diff = day.difference(today).inDays;
      return diff >= 0 && diff <= 1;
    }).toList();
    if (soon.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final c in soon)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            onTap: () => context.go('/camps'),
            child: Row(children: [
              const Icon(Icons.notifications_active, color: AppColors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                      DateTime(c.date.year, c.date.month, c.date.day) == today
                          ? 'Camp today'
                          : 'Camp tomorrow',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  FieldLabel('${c.title} · ${c.place} · ${DateFormat('h:mm a').format(c.date)}'),
                ]),
              ),
            ]),
          ),
        ),
    ]);
  }
}