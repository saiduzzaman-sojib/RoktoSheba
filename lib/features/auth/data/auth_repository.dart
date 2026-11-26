import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/dhaka_areas.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/utils/eligibility.dart';
import '../../donors/models/donor.dart';
import '../../legal/consent.dart';

/// "+8801712345678", "880 1712-345678" -> "01712345678"
String normalizeMobile(String input) {
  var v = input.replaceAll(RegExp(r'[\s\-()]'), '');
  if (v.startsWith('+880')) v = '0${v.substring(4)}';
  if (v.startsWith('880') && v.length == 13) v = '0${v.substring(3)}';
  return v;
}

bool isValidMobile(String input) =>
    RegExp(r'^01[3-9]\d{8}$').hasMatch(normalizeMobile(input));

/// Returns a message already translated to the current language.
String authErrorMessage(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-email':
        return tr('Wrong mobile/email or password.');
      case 'email-already-in-use':
        return tr('This mobile number is already registered. Please log in.');
      case 'weak-password':
        return tr(
            'Password is too weak. Use at least 8 characters with letters and numbers.');
      case 'requires-recent-login':
        return tr('Please log in again, then try once more.');
      case 'network-request-failed':
        return tr('No internet connection. Please try again.');
      case 'too-many-requests':
        return tr('Too many attempts. Please wait a minute and try again.');
      case 'operation-not-allowed':
        return tr('Email/Password sign-in is not enabled in Firebase console.');
      default:
        return trp('Login problem ({code}).', {'code': e.code});
    }
  }
  if (e is FirebaseException && e.code == 'permission-denied') {
    return tr(
        'Could not save your profile (permission denied). Check Firestore rules.');
  }
  return tr('Something went wrong. Please try again.');
}

class AuthRepository {
  AuthRepository(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// A real email is used as is; a mobile number becomes a hidden email.
  static String emailFor(String input) {
    final v = input.trim();
    if (v.contains('@')) return v.toLowerCase();
    return '${normalizeMobile(v)}@donor.roktosheba.app';
  }

  Future<void> signIn(String idOrMobile, String password) =>
      _auth.signInWithEmailAndPassword(
          email: emailFor(idOrMobile), password: password);

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();

  Future<void> register({
    required String name,
    required String mobile,
    required String password,
    required String bloodGroup,
    required String district,
    required String area,
    DateTime? lastDonation,
    String? photoB64,
  }) async {
    final cleanMobile = normalizeMobile(mobile);
    final email = emailFor(cleanMobile);
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = cred.user!;
    try {
      await user.updateDisplayName(name);

      // Not eligible yet (donated within the gap)? Start as unavailable.
      final next = nextEligibleDate(lastDonation);
      final eligible = next == null || !next.isAfter(DateTime.now());

      final ap = areaPoint(area);
      final donor = Donor(
        uid: user.uid,
        name: name,
        bloodGroup: bloodGroup,
        district: district,
        area: area,
        available: eligible,
        verified: false,
        lastDonation: lastDonation,
        photoB64: photoB64,
        location: ap == null ? null : GeoPoint(ap.latitude, ap.longitude),
      );

      final batch = _db.batch();
      batch.set(_db.collection(FS.users).doc(user.uid), {
        'name': name,
        'email': email,
        'role': 'user',
        'language': currentLang,
        'termsVersion': termsVersion,
        'termsAcceptedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(_db.collection(FS.donors).doc(user.uid), donor.toMap());
      batch.set(_db.collection(FS.donorPrivate).doc(user.uid),
          {'mobile': cleanMobile});
      await batch.commit();
    } catch (e) {
      // Do not leave a half-created account behind.
      await user.delete();
      rethrow;
    }
  }

  /// Re-checks the password, removes the profile data, then the login itself.
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;
    await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password));
    final batch = _db.batch();
    batch.delete(_db.collection(FS.donorPrivate).doc(user.uid));
    batch.delete(_db.collection(FS.donors).doc(user.uid));
    batch.delete(_db.collection(FS.users).doc(user.uid));
    await batch.commit();
    await user.delete();
  }
}