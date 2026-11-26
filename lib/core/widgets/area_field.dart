import 'package:flutter/material.dart';
import '../constants/dhaka_areas.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

/// Text field that suggests areas while typing. Free text is still allowed.
class AreaField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  const AreaField({super.key, required this.controller, this.hint});

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (v) => areaSuggestions(v.text),
      onSelected: (s) => controller.text = s,
      fieldViewBuilder: (context, c, focus, onSubmit) => TextField(
        controller: c,
        focusNode: focus,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: hint ?? tr('Area')),
        onSubmitted: (_) => onSubmit(),
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(14),
          color: context.surface,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 260),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final o in options)
                  InkWell(
                    onTap: () => onSelected(o),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Icon(Icons.place_outlined, size: 18, color: context.accent),
                        const SizedBox(width: 10),
                        Text(o, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ]),
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