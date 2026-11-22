import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Increase this number when the terms change; users will be asked again.
const termsVersion = 1;
const _key = 'terms_version';

final termsAccepted = ValueNotifier<bool>(false);

Future<void> loadConsent() async {
  final p = await SharedPreferences.getInstance();
  termsAccepted.value = (p.getInt(_key) ?? 0) >= termsVersion;
}

Future<void> acceptTerms() async {
  final p = await SharedPreferences.getInstance();
  await p.setInt(_key, termsVersion);
  termsAccepted.value = true;
}