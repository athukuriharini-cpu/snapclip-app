import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/category.dart';
import '../../providers/categories_provider.dart';
import '../../providers/subscription_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedColorValue = AppColors.categoryColors.first.value;
  String _selectedIcon = '📁';

  final List<String> _emojiPresets = [
    '📁', '💼', '💡', '💻', '🔗', '📝', '🎯', '🚀', '⭐', '🏷️', '📚', '🛠️'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    final isPro = ref.read(isProProvider);
    final count = ref.read(categoriesProvider).length;

    if (!isPro && count >= 3) {
      context.showSnackBar('Free plan allows up to 3 categories. Upgrade to Pro for unlimited!');
      return;
    }

    _nameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Code Snippets',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Choose Icon', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _emojiPresets.map((emoji) {
                    final isSel = _selectedIcon == emoji;
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setDialogState(() => _selectedIcon = emoji),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary.withOpacity(0.2) : null,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? AppColors.primary : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Choose Color', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppColors.categoryColors.map((color) {
                    final isSel = _selectedColorValue == color.value;
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setDialogState(() => _selectedColorValue = color.value),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) return;
                final newCat = CategoryModel(
                  name: _nameController.text.trim(),
                  colorValue: _selectedColorValue,
                  icon: _selectedIcon,
                );
                ref.read(categoriesProvider.notifier).add(newCat);
                Navigator.of(ctx).pop();
                context.showSnackBar('Category created! ✨');
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📁', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  const Text(
                    'No custom categories yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Organize your snippets with colored tags and icons.',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Category'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(cat.colorValue).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(cat.icon, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      onPressed: () => ref.read(categoriesProvider.notifier).delete(cat.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
