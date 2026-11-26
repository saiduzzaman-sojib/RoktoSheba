import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'strings.dart';

/// Current language code: 'en' or 'bn'.
String currentLang = 'en';

bool get isBn => currentLang == 'bn';

/// Translate an English string. Falls back to the English text.
String tr(String en) => isBn ? (bnStrings[en] ?? en) : en;

const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

/// Shows digits as Bangla digits in Bangla mode.
String bnNum(Object v) {
  final s = '$v';
  if (!isBn) return s;
  return s.replaceAllMapped(
      RegExp(r'[0-9]'), (m) => _bnDigits[int.parse(m.group(0)!)]);
}

/// Translate a template and fill {name} placeholders.
/// Numbers (and number-like text such as "2.5") use Bangla digits in Bangla mode.
String trp(String en, Map<String, Object> params) {
  var s = tr(en);
  params.forEach((k, v) {
    final t = '$v';
    final numeric = v is num || RegExp(r'^[0-9.]+$').hasMatch(t);
    s = s.replaceAll('{$k}', numeric ? bnNum(v) : t);
  });
  return s;
}

const _bnMonths = [
  'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
  'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
];
const _enMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String monthShort(int month) =>
    isBn ? _bnMonths[month - 1] : _enMonths[month - 1];

/// 5 Feb 2027  /  ৫ ফেব্রুয়ারি ২০২৭
String fmtDate(DateTime d) =>
    '${bnNum(d.day)} ${monthShort(d.month)} ${bnNum(d.year)}';

class LangNotifier extends Notifier<String> {
  static const _key = 'lang';

  @override
  String build() {
    _load();
    return currentLang;
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getString(_key) ?? 'en';
      currentLang = v;
      state = v;
    } catch (_) {}
  }

  Future<void> set(String code) async {
    currentLang = code;
    state = code;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key, code);
    } catch (_) {}
  }
}

final langProvider = NotifierProvider<LangNotifier, String>(LangNotifier.new);

/// Wrap the app so every screen rebuilds when the language changes.
class LangScope extends ConsumerWidget {
  final Widget child;
  const LangScope({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    return KeyedSubtree(key: ValueKey(lang), child: child);
  }
}