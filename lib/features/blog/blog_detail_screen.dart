import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/back_link.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'blog_provider.dart';

class BlogDetailScreen extends ConsumerWidget {
  final String id;
  const BlogDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(blogPostProvider(id));
    return async.when(
      loading: () => const AppPage(navPadding: false, children: [
        SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator(color: AppColors.red))),
      ]),
      error: (_, _) => const AppPage(navPadding: false, children: [
        BackLink('Back'),
        FieldLabel('Could not load this article.'),
      ]),
      data: (p) {
        if (p == null) {
          return const AppPage(navPadding: false, children: [
            BackLink('Back'),
            FieldLabel('This article no longer exists.'),
          ]);
        }
        return AppPage(navPadding: false, children: [
          const BackLink('Back'),
          Text(p.category.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.red)),
          Text(p.title,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -.5)),
          FieldLabel('${p.author} · ${DateFormat('d MMM yyyy').format(p.date)}'),
          for (final para in p.content.split(RegExp(r'\n\s*\n')))
            Text(para.trim(), style: const TextStyle(fontSize: 15, height: 1.6)),
        ]);
      },
    );
  }
}