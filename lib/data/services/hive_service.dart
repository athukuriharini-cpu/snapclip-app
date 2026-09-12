import 'package:hive_flutter/hive_flutter.dart';
import '../models/snippet.dart';
import '../models/category.dart';
import '../../core/constants/app_constants.dart';

class HiveService {
  static Box<Snippet> get _snippetsBox =>
      Hive.box<Snippet>(AppConstants.snippetsBox);
  static Box<CategoryModel> get _categoriesBox =>
      Hive.box<CategoryModel>(AppConstants.categoriesBox);
  static Box get _settingsBox => Hive.box(AppConstants.settingsBox);

  // ─── Snippets ────────────────────────────────────────────

  static List<Snippet> getAllSnippets() {
    return _snippetsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static List<Snippet> getSnippetsByCategory(String categoryId) {
    return _snippetsBox.values
        .where((s) => s.categoryId == categoryId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static List<Snippet> getFavoriteSnippets() {
    return _snippetsBox.values.where((s) => s.isFavorite).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static List<Snippet> searchSnippets(String query) {
    final q = query.toLowerCase();
    return _snippetsBox.values
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.content.toLowerCase().contains(q) ||
            s.tags.any((t) => t.toLowerCase().contains(q)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static Future<void> saveSnippet(Snippet snippet) async {
    await _snippetsBox.put(snippet.id, snippet);
  }

  static Future<void> deleteSnippet(String id) async {
    await _snippetsBox.delete(id);
  }

  static Future<void> toggleFavorite(Snippet snippet) async {
    snippet.isFavorite = !snippet.isFavorite;
    await snippet.save();
  }

  static int get snippetCount => _snippetsBox.length;

  // ─── Categories ──────────────────────────────────────────

  static List<CategoryModel> getAllCategories() {
    return _categoriesBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  static Future<void> saveCategory(CategoryModel category) async {
    await _categoriesBox.put(category.id, category);
  }

  static Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
    for (final snippet in _snippetsBox.values.where((s) => s.categoryId == id)) {
      snippet.categoryId = '';
      await snippet.save();
    }
  }

  static int get categoryCount => _categoriesBox.length;

  // ─── Settings ────────────────────────────────────────────

  static bool get isOnboardingComplete =>
      _settingsBox.get(AppConstants.onboardingCompleteKey, defaultValue: false);

  static Future<void> setOnboardingComplete() async {
    await _settingsBox.put(AppConstants.onboardingCompleteKey, true);
  }

  static int get paywallDismissCount =>
      _settingsBox.get(AppConstants.paywallDismissCountKey, defaultValue: 0);

  static Future<void> incrementPaywallDismissCount() async {
    await _settingsBox.put(
      AppConstants.paywallDismissCountKey,
      paywallDismissCount + 1,
    );
  }
}
