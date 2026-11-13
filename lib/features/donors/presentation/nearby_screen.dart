import 'package:flutter/material.dart';
import '../../../core/widgets/gradient_scaffold.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});
  @override
  Widget build(BuildContext context) => const AppPage(children: [
        Text('Donors near you',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        FieldLabel('Live map and list come in Step 5.'),
      ]);
}