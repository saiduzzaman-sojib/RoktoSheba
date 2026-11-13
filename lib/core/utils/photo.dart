import 'dart:convert';
import 'package:image_picker/image_picker.dart';

/// Picks a photo, shrinks it to max 256px and returns it as base64 text
/// (about 15-30 KB), so it can be stored inside a Firestore document.
Future<String?> pickPhotoB64() async {
  final x = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 256,
    maxHeight: 256,
    imageQuality: 70,
  );
  if (x == null) return null;
  return base64Encode(await x.readAsBytes());
}