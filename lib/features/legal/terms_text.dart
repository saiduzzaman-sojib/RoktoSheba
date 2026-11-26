import '../../core/l10n/l10n.dart';

class TermsSection {
  final String _title, _body;
  const TermsSection(this._title, this._body);

  String get title => tr(_title);
  String get body => tr(_body);
}

const termsSections = <TermsSection>[
  TermsSection('What Roktosheba is',
      'Roktosheba helps people find voluntary blood donors nearby. We do not collect, store or supply blood.'),
  TermsSection('Who can use it',
      'You must be 18 or older. Donate only if you are healthy and meet the donation rules. The final decision is always made by the hospital or blood bank, not this app.'),
  TermsSection('Not medical advice',
      'The app gives general information only. It does not replace a doctor. In an emergency, call 999 or go to the nearest hospital.'),
  TermsSection('Blood donation is free',
      'Donating and requesting blood here is voluntary. Never ask for or offer money for blood.'),
  TermsSection('What we collect',
      'Your name, blood group, area, approximate location (rounded to about 100 m), mobile number, photo and donation dates.'),
  TermsSection('Who sees it',
      'Signed-in users can see your name, photo, blood group, area and availability. Your mobile number is shared only with the person you choose to help, and only after you accept their request. We do not sell your data.'),
  TermsSection('Your responsibilities',
      'Give true information. Do not post fake or spam requests. Do not harass anyone or misuse another person\'s contact details.'),
  TermsSection('Restrictions',
      'Admins can restrict or remove accounts that misuse the app.'),
  TermsSection('Your control',
      'You can turn availability off, edit your details, or delete your account from Profile at any time. Deleting removes your profile and phone number.'),
  TermsSection('Changes',
      'If these terms change, we will ask you to agree again.'),
];