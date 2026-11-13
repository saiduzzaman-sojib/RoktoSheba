import 'package:flutter/material.dart';
import '../../core/widgets/gradient_scaffold.dart';

class CampsScreen extends StatelessWidget {
  const CampsScreen({super.key});
  @override
  Widget build(BuildContext context) => const AppPage(children: [
        Text('Donation camps',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        FieldLabel('Camps list comes in Step 7.'),
      ]);
}