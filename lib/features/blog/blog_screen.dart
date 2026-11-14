import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/back_link.dart';
import '../../core/widgets/blood_chip.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'blog_provider.dart';

class BlogScreen extends ConsumerStatefulWidget {
  const BlogScreen({super.key});
  @override
  ConsumerState<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends ConsumerState<BlogScreen> {
  // label -> value stored in Firestore
  static const _cats = {'All': '', 'Tips': 'Tip', 'Myths': 'Myth', 'Stories': 'Story'};
  String _cat = 'All';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(blogPostsProvider);
    final want = _cats[_cat]!;
    final posts = (async.value ?? const [])
        .where((p) => want.isEmpty || p.category == want)
        .toList();

    return AppPage(navPadding: false, children: [
      const BackLink('Back'),
      const Text('Health tips & stories',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final c in _cats.keys) ...[
            BloodChip(label: c, selected: _cat == c, onTap: () => setState(() => _cat = c)),
            const SizedBox(width: 8),
          ],
        ]),
      ),
      if (async.isLoading && !async.hasValue)
        const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator(color: AppColors.red)))
      else if (async.hasError && !async.hasValue)
        const FieldLabel('Could not load articles. Check your internet.')
      else if (posts.isEmpty)
        const FieldLabel('Nothing here yet.'),
      for (final p in posts)
        AppCard(
          onTap: () => context.push('/blog/${p.id}'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${p.category.toUpperCase()} · ${DateFormat('d MMM yyyy').format(p.date)}',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.red)),
            const SizedBox(height: 6),
            Text(p.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            FieldLabel(p.excerpt.replaceAll('\n', ' ')),
          ]),
        ),
    ]);
  }
}