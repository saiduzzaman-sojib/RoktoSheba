import 'package:url_launcher/url_launcher.dart';

class ShareUtils {
  /// Nijer web link-e boshao
  static const appLink = 'https://saiduzzaman-sojib.github.io/RoktoSheba/';

  /// 01712345678 / +8801712345678 → 8801712345678
  static String bdPhone(String raw) {
    final d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('880')) return d;
    if (d.startsWith('0')) return '880${d.substring(1)}';
    return '880$d';
  }

  static String requestText({
    required String bloodGroup,
    required int units,
    required String hospital,
    required String area,
    required String district,
    required String urgency,
  }) {
    return '🆘 *URGENT BLOOD NEEDED*\n\n'
        '🩸 Blood group: *$bloodGroup* ($units bag)\n'
        '🏥 Hospital: $hospital\n'
        '📍 Location: $area, $district\n'
        '⚠️ Urgency: $urgency\n\n'
        'Please donate or share this message with others. 🙏\n'
        'Find donors on Roktosheba: $appLink';
  }

  /// [phone] dile oi number-e direct message, na dile contact/group choose korte dibe.
  static Future<bool> whatsApp(String text, {String? phone}) {
    final base =
        phone == null ? 'https://wa.me/' : 'https://wa.me/${bdPhone(phone)}';
    final uri = Uri.parse('$base?text=${Uri.encodeComponent(text)}');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}