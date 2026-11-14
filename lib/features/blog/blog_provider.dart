import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/firestore_paths.dart';
import 'blog_post.dart';

final blogPostsProvider = StreamProvider<List<BlogPost>>((ref) {
  return FirebaseFirestore.instance
      .collection(FS.blogs)
      .orderBy('date', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(BlogPost.fromDoc).toList());
});

final blogPostProvider = StreamProvider.family<BlogPost?, String>((ref, id) {
  return FirebaseFirestore.instance
      .collection(FS.blogs)
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? BlogPost.fromDoc(d) : null);
});