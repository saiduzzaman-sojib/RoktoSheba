import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_paths.dart';

/// Writes sample camps and articles with fixed ids, so pressing it again
/// replaces them instead of duplicating. Needs an admin account.
Future<void> seedSampleData() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  final now = DateTime.now();
  DateTime at(int days, int hour) =>
      DateTime(now.year, now.month, now.day + days, hour);

  final camps = [
    {
      'id': 'sample-camp-1',
      'title': 'University Blood Drive',
      'place': 'Campus auditorium',
      'organizer': 'Red Crescent Youth',
      'district': 'Dhaka',
      'description': 'Walk in with a photo ID. Eat well beforehand.',
      'date': at(1, 10),
      'location': const GeoPoint(23.7285, 90.3980),
    },
    {
      'id': 'sample-camp-2',
      'title': 'Community Health Camp',
      'place': 'Local club ground',
      'organizer': 'Neighbourhood Welfare Society',
      'district': 'Dhaka',
      'description': 'Free blood group check and donation.',
      'date': at(7, 9),
      'location': const GeoPoint(23.8200, 90.4250),
    },
    {
      'id': 'sample-camp-3',
      'title': 'Hospital Donation Day',
      'place': 'Main hospital lobby',
      'organizer': 'City Hospital',
      'district': 'Dhaka',
      'description': 'Donations support the hospital blood bank.',
      'date': at(14, 11),
      'location': const GeoPoint(23.7900, 90.4000),
    },
  ];
  for (final c in camps) {
    final id = c.remove('id') as String;
    batch.set(db.collection(FS.camps).doc(id), {
      ...c,
      'date': Timestamp.fromDate(c['date'] as DateTime),
    });
  }

  final posts = [
    {
      'id': 'sample-blog-1',
      'category': 'Tip',
      'title': 'How to prepare before you donate',
      'content':
          'Drink plenty of water and eat a healthy meal in the hours before you donate. '
          'Avoid fatty food just before, and get a good night of sleep.\n\n'
          'Bring a photo ID and wear a shirt with sleeves that roll up easily. '
          'Tell the staff about any medicine you take or any recent illness.',
    },
    {
      'id': 'sample-blog-2',
      'category': 'Tip',
      'title': 'After donating: the first 24 hours',
      'content':
          'Rest for a few minutes and have a drink and a snack before you leave. '
          'Drink extra fluids for the rest of the day.\n\n'
          'Avoid heavy lifting and hard exercise until the next day. '
          'If you feel dizzy, sit or lie down until it passes.',
    },
    {
      'id': 'sample-blog-3',
      'category': 'Myth',
      'title': 'Myth: donating blood makes you weak',
      'content':
          'A healthy adult donates about one unit, which the body is built to replace. '
          'Plasma is restored within a day or two, and red cells within a few weeks.\n\n'
          'That is why donors must wait about three months between donations, '
          'and why the app keeps you hidden until you are eligible again.',
    },
    {
      'id': 'sample-blog-4',
      'category': 'Myth',
      'title': 'Myth: giving blood takes hours',
      'content':
          'The blood collection itself takes around ten minutes. '
          'With the health check and a short rest afterwards, the whole visit is usually under an hour.',
    },
    {
      'id': 'sample-blog-5',
      'category': 'Story',
      'title': 'Sample story: a call that came in time',
      'content':
          'This is a sample story to show how stories look in the app.\n\n'
          'A family needed rare blood late at night. Instead of dozens of calls, '
          'a request reached nearby matching donors, one accepted within minutes, '
          'and the patient got the blood in time. Every donor on the map is one more chance like this.',
    },
  ];
  for (var i = 0; i < posts.length; i++) {
    final p = posts[i];
    batch.set(db.collection(FS.blogs).doc(p['id'] as String), {
      'title': p['title'],
      'content': p['content'],
      'category': p['category'],
      'author': 'Roktosheba Team',
      'date': Timestamp.fromDate(now.subtract(Duration(days: i))),
    });
  }
  await batch.commit();
}