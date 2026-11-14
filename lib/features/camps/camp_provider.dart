import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/firestore_paths.dart';
import 'camp.dart';

/// All camps, soonest first. "Upcoming" is filtered on the device.
final campsProvider = StreamProvider<List<Camp>>((ref) {
  return FirebaseFirestore.instance
      .collection(FS.camps)
      .orderBy('date')
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(Camp.fromDoc).toList());
});

/// Camp ids the user wants a reminder for (saved on this phone).
class RemindersNotifier extends Notifier<Set<String>> {
  static const _key = 'camp_reminders';

  @override
  Set<String> build() {
    _load();
    return <String>{};
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = (p.getStringList(_key) ?? <String>[]).toSet();
  }

  Future<bool> toggle(String id) async {
    final next = {...state};
    final added = next.add(id);
    if (!added) next.remove(id);
    state = next;
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_key, next.toList());
    return added;
  }
}

final campRemindersProvider =
    NotifierProvider<RemindersNotifier, Set<String>>(RemindersNotifier.new);