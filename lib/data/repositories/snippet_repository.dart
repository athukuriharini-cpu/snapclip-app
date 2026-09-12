import '../models/snippet.dart';
import '../models/category.dart';
import '../services/hive_service.dart';
import '../../core/constants/app_constants.dart';

class SnippetRepository {
  List<Snippet> getAll() => HiveService.getAllSnippets();

  List<Snippet> getByCategory(String categoryId) =>
      HiveService.getSnippetsByCategory(categoryId);

  List<Snippet> getFavorites() => HiveService.getFavoriteSnippets();

  List<Snippet> search(String query) => HiveService.searchSnippets(query);

  Future<void> save(Snippet snippet) => HiveService.saveSnippet(snippet);

  Future<void> delete(String id) => HiveService.deleteSnippet(id);

  Future<void> toggleFavorite(Snippet snippet) =>
      HiveService.toggleFavorite(snippet);

  int get count => HiveService.snippetCount;

  bool get isAtFreeLimit => count >= AppConstants.freeSnippetLimit;
}

class CategoryRepository {
  List<CategoryModel> getAll() => HiveService.getAllCategories();

  Future<void> save(CategoryModel category) =>
      HiveService.saveCategory(category);

  Future<void> delete(String id) => HiveService.deleteCategory(id);

  int get count => HiveService.categoryCount;

  bool get isAtFreeLimit => count >= AppConstants.freeCategoryLimit;
}
