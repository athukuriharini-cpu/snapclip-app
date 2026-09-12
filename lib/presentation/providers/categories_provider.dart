import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category.dart';
import '../../data/repositories/snippet_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<CategoryModel>>((ref) {
  return CategoriesNotifier(ref.watch(categoryRepositoryProvider));
});

class CategoriesNotifier extends StateNotifier<List<CategoryModel>> {
  final CategoryRepository _repo;

  CategoriesNotifier(this._repo) : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAll();
  }

  Future<void> add(CategoryModel category) async {
    await _repo.save(category);
    _load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _load();
  }

  bool get isAtFreeLimit => _repo.isAtFreeLimit;
  int get count => _repo.count;
}
