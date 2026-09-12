import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/snippet.dart';
import '../../providers/snippets_provider.dart';
import '../../providers/categories_provider.dart';

class SnippetDetailScreen extends ConsumerWidget {
  final Snippet snippet;

  const SnippetDetailScreen({super.key, required this.snippet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.watch(categoriesProvider);
    final category = categories.firstWhere(
      (c) => c.id == snippet.categoryId,
      orElse: () => null as dynamic,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(snippet.title),
        actions: [
          IconButton(
            icon: Icon(
              snippet.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: snippet.isFavorite ? AppColors.warning : null,
            ),
            onPressed: () {
              ref.read(snippetsProvider.notifier).toggleFavorite(snippet);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/add', extra: snippet),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Share.share(snippet.content, subject: snippet.title),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header: Emoji badge + Category + Created timestamp
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(snippet.typeEmoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snippet.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Created ${snippet.createdAt.friendlyDate}',
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(category.colorValue).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(category.colorValue),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Action bar if link
          if (snippet.type == SnippetType.link && snippet.content.isUrl) ...[
            FilledButton.tonalIcon(
              onPressed: () async {
                final uri = Uri.parse(snippet.content);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_browser_rounded),
              label: const Text('Open Link in Browser'),
            ),
            const SizedBox(height: 16),
          ],

          // Main Content Viewer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2A2A45) : const Color(0xFFE8E8F5),
              ),
            ),
            child: SelectableText(
              snippet.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                fontFamily: snippet.type == SnippetType.code ? 'Courier' : null,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tags section
          if (snippet.tags.isNotEmpty) ...[
            const Text(
              'Tags',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: snippet.tags
                  .map(
                    (tag) => Chip(
                      label: Text('#$tag'),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Big Copy Button
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: snippet.content));
                HapticFeedback.mediumImpact();
                context.showSnackBar('Snippet copied to clipboard! 📋');
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.copy_rounded),
              label: const Text(
                'Copy to Clipboard',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
