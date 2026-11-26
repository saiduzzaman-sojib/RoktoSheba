import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/l10n.dart';
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
  static const _cats = {'All posts': '', 'Tips': 'Tip', 'Myths': 'Myth', 'Stories': 'Story'};
  String _cat = 'All posts';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(blogPostsProvider);
    final want = _cats[_cat]!;
    final posts = (async.value ?? const [])
        .where((p) => want.isEmpty || p.category == want)
        .toList();

    return AppPage(navPadding: false, children: [
      const BackLink('Back'),
      Text(tr('Health tips & stories'),
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.6)),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final c in _cats.keys) ...[
            BloodChip(
                label: tr(c),
                selected: _cat == c,
                onTap: () => setState(() => _cat = c)),
            const SizedBox(width: 8),
          ],
        ]),
      ),
      if (async.isLoading && !async.hasValue)
        const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator(color: AppColors.red)))
      else if (async.hasError && !async.hasValue)
        FieldLabel(tr('Could not load articles. Check your internet.'))
      else if (posts.isEmpty)
        FieldLabel(tr('Nothing here yet.')),
      for (final p in posts)
        AppCard(
          onTap: () => context.push('/blog/${p.id}'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${tr(p.category).toUpperCase()} · ${fmtDate(p.date)}',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800, color: context.accent)),
            const SizedBox(height: 6),
            Text(p.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            FieldLabel(p.excerpt.replaceAll('\n', ' ')),
          ]),
        ),
    ]);
  }
}