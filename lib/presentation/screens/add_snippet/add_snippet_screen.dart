import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/snippet.dart';
import '../../providers/snippets_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/subscription_provider.dart';

class AddSnippetScreen extends ConsumerStatefulWidget {
  final Snippet? snippet;

  const AddSnippetScreen({super.key, this.snippet});

  @override
  ConsumerState<AddSnippetScreen> createState() => _AddSnippetScreenState();
}

class _AddSnippetScreenState extends ConsumerState<AddSnippetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late SnippetType _selectedType;
  late String _selectedCategoryId;
  late bool _isFavorite;

  bool get _isEditing => widget.snippet != null;

  @override
  void initState() {
    super.initState();
    final s = widget.snippet;
    _titleController = TextEditingController(text: s?.title ?? '');
    _contentController = TextEditingController(text: s?.content ?? '');
    _tagsController = TextEditingController(text: s?.tags.join(', ') ?? '');
    _selectedType = s?.type ?? SnippetType.text;
    _selectedCategoryId = s?.categoryId ?? '';
    _isFavorite = s?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        if (_contentController.text.isEmpty) {
          _contentController.text = data.text!;
          if (_titleController.text.isEmpty) {
            _titleController.text = data.text!.firstLine.truncated80;
          }
        } else {
          _contentController.text += '\n${data.text!}';
        }
      });
      if (mounted) context.showSnackBar('Pasted from clipboard! 📋');
    }
  }

  void _saveSnippet() async {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (_isEditing) {
      final updated = widget.snippet!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        categoryId: _selectedCategoryId,
        tags: tags,
        isFavorite: _isFavorite,
      );
      await ref.read(snippetsProvider.notifier).update(updated);
      if (mounted) {
        context.showSnackBar('Snippet updated');
        context.pop();
      }
    } else {
      final isPro = ref.read(isProProvider);
      final count = ref.read(snippetsProvider.notifier).count;
      if (!isPro && count >= 10) {
        context.push('/paywall', extra: 'Unlock unlimited snippets with Pro');
        return;
      }

      final newSnippet = Snippet(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        categoryId: _selectedCategoryId,
        tags: tags,
        isFavorite: _isFavorite,
      );
      await ref.read(snippetsProvider.notifier).add(newSnippet);
      if (mounted) {
        context.showSnackBar('Snippet saved 🎉');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Snippet' : 'New Snippet'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _isFavorite ? AppColors.warning : null,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          IconButton(
            icon: const Icon(Icons.paste_rounded),
            tooltip: 'Paste from clipboard',
            onPressed: _pasteFromClipboard,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Snippet Type Selector
            Row(
              children: [
                _buildTypeOption(SnippetType.text, 'Text', '📝'),
                const SizedBox(width: 8),
                _buildTypeOption(SnippetType.code, 'Code', '💻'),
                const SizedBox(width: 8),
                _buildTypeOption(SnippetType.link, 'Link', '🔗'),
                const SizedBox(width: 8),
                _buildTypeOption(SnippetType.image, 'Image', '🖼️'),
              ],
            ),
            const SizedBox(height: 20),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Weekly Standup Template',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),

            // Content Field
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              style: TextStyle(
                fontFamily: _selectedType == SnippetType.code ? 'Courier' : null,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                labelText: 'Snippet Content',
                hintText: 'Type or paste your snippet text, link or script here...',
                alignLabelWithHint: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste_go_rounded, size: 20),
                  onPressed: _pasteFromClipboard,
                ),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Content cannot be empty' : null,
            ),
            const SizedBox(height: 16),

            // Category Picker
            DropdownButtonFormField<String>(
              value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Uncategorized'),
                ),
                ...categories.map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        Text(c.icon),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => _selectedCategoryId = val ?? ''),
            ),
            const SizedBox(height: 16),

            // Tags Field
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                hintText: 'work, template, email',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saveSnippet,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Update Snippet' : 'Save Snippet',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(SnippetType type, String label, String icon) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (type == SnippetType.image) {
            final isPro = ref.read(isProProvider);
            if (!isPro) {
              context.push('/paywall', extra: 'Image snippets are a SnapClip Pro feature');
              return;
            }
          }
          setState(() => _selectedType = type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.18)
                : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
