import 'package:flutter/material.dart';
import '../../../core/widgets/gradient_scaffold.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});
  @override
  Widget build(BuildContext context) => const AppPage(children: [
        Text('Request blood',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        FieldLabel('Blood requests come in Step 6.'),
      ]);
}