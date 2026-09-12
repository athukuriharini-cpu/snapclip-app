import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category.dart';
import '../../providers/snippets_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/snippet_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/premium_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final snippets = ref.watch(filteredSnippetsProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isPro = ref.watch(isProProvider);
    final totalSnippetCount = ref.watch(snippetsProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'SnapClip',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(width: 8),
            if (!isPro)
              PremiumBadge(
                onTap: () => context.push('/paywall', extra: 'Unlock Unlimited Snippets & Features'),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Usage banner for free users
          if (!isPro)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: totalSnippetCount >= AppConstants.freeSnippetLimit
                      ? AppColors.warning
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    totalSnippetCount >= AppConstants.freeSnippetLimit
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                    color: totalSnippetCount >= AppConstants.freeSnippetLimit
                        ? AppColors.warning
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Free plan: $totalSnippetCount / ${AppConstants.freeSnippetLimit} snippets used',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push(
                      '/paywall',
                      extra: 'Get unlimited snippets with SnapClip Pro',
                    ),
                    child: const Text(
                      'Upgrade',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Categories horizontal scroll list
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryChip(
                  category: CategoryModel(
                    id: '',
                    name: 'All',
                    colorValue: 0xFF6C63FF,
                    icon: '✨',
                  ),
                  isSelected: selectedCategory.isEmpty,
                  onTap: () => ref.read(selectedCategoryProvider.notifier).state = '',
                ),
                ...categories.map(
                  (cat) => CategoryChip(
                    category: cat,
                    isSelected: selectedCategory == cat.id,
                    onTap: () => ref.read(selectedCategoryProvider.notifier).state = cat.id,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                  onPressed: () => context.push('/categories'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Snippet Feed or Empty State
          Expanded(
            child: snippets.isEmpty
                ? EmptyStateWidget(
                    title: selectedCategory.isEmpty
                        ? 'No snippets yet'
                        : 'No snippets in this category',
                    description:
                        'Tap the + button below to create your first fast snippet, reusable template, or note.',
                    buttonText: 'Add Snippet',
                    onButtonPressed: () => _navigateToAdd(context, ref, isPro, totalSnippetCount),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 88),
                    itemCount: snippets.length,
                    itemBuilder: (context, index) {
                      return SnippetCard(snippet: snippets[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(context, ref, isPro, totalSnippetCount),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Snippet', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _navigateToAdd(BuildContext context, WidgetRef ref, bool isPro, int totalSnippetCount) {
    if (!isPro && totalSnippetCount >= AppConstants.freeSnippetLimit) {
      context.push(
        '/paywall',
        extra: 'You reached the free limit of 10 snippets. Unlock unlimited with SnapClip Pro!',
      );
    } else {
      context.push('/add');
    }
  }
}
