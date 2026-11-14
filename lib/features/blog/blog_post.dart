import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id, title, content, author, category; // category: Tip, Myth or Story
  final DateTime date;

  const BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    required this.date,
  });

  String get excerpt =>
      content.length <= 110 ? content : '${content.substring(0, 110).trimRight()}...';

  factory BlogPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return BlogPost(
      id: d.id,
      title: m['title'] ?? '',
      content: m['content'] ?? '',
      author: m['author'] ?? 'Roktosheba',
      category: m['category'] ?? 'Tip',
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}