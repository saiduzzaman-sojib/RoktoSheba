import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greet() {
    final h = DateTime.now().hour;
    return h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donor = ref.watch(myDonorProvider).value;
    final name = donor?.name ?? '';
    return AppPage(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldLabel(_greet()),
              Text(name.isEmpty ? '...' : name.split(' ').last,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
            ],
          ),
          Avatar(bytes: donor?.photoBytes, name: name),
        ],
      ),
      AppCard(
        dark: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your status', style: TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              donor == null
                  ? 'Loading...'
                  : donor.available ? 'Available to donate' : 'Not available',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text('Blood group ${donor?.bloodGroup ?? ''}',
                style: const TextStyle(fontSize: 13, color: Colors.white70)),
          ],
        ),
      ),
      const FieldLabel('Home dashboard comes in Step 4.'),
    ]);
  }
}