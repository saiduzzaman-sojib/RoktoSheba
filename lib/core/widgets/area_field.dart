import 'package:flutter/material.dart';
import '../constants/dhaka_areas.dart';
import '../theme/app_colors.dart';

/// Text field that suggests areas while typing. Free text is still allowed.
class AreaField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const AreaField({super.key, required this.controller, this.hint = 'Area'});

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
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (_) => onSubmit(),
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
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
                        const Icon(Icons.place_outlined, size: 18, color: AppColors.red),
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