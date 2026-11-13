import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donor = ref.watch(myDonorProvider).value;
    return AppPage(children: [
      Row(
        children: [
          Avatar(bytes: donor?.photoBytes, name: donor?.name ?? '', size: 88, radius: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donor?.name ?? '...',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                FieldLabel('Donor, ${donor?.district ?? ''}'),
              ],
            ),
          ),
        ],
      ),
      FieldLabel('Blood group: ${donor?.bloodGroup ?? ''}'),
      const FieldLabel('Photo change, history and settings come in Step 4.'),
      AppButton(
        label: 'Log out',
        onPressed: () => ref.read(authRepositoryProvider).signOut(),
      ),
    ]);
  }
}