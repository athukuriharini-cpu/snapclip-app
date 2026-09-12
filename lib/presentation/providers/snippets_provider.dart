import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/snippet.dart';
import '../../data/repositories/snippet_repository.dart';

final snippetRepositoryProvider = Provider<SnippetRepository>((ref) {
  return SnippetRepository();
});

final selectedCategoryProvider = StateProvider<String>((ref) => '');

final snippetsProvider = StateNotifierProvider<SnippetsNotifier, List<Snippet>>((ref) {
  return SnippetsNotifier(ref.watch(snippetRepositoryProvider));
});

final filteredSnippetsProvider = Provider<List<Snippet>>((ref) {
  final snippets = ref.watch(snippetsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  if (selectedCategory.isEmpty) return snippets;
  return snippets.where((s) => s.categoryId == selectedCategory).toList();
});

final favoriteSnippetsProvider = Provider<List<Snippet>>((ref) {
  return ref.watch(snippetsProvider).where((s) => s.isFavorite).toList();
});

class SnippetsNotifier extends StateNotifier<List<Snippet>> {
  final SnippetRepository _repo;

  SnippetsNotifier(this._repo) : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAll();
  }

  Future<void> add(Snippet snippet) async {
    await _repo.save(snippet);
    _load();
  }

  Future<void> update(Snippet snippet) async {
    await _repo.save(snippet);
    _load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _load();
  }

  Future<void> toggleFavorite(Snippet snippet) async {
    await _repo.toggleFavorite(snippet);
    _load();
  }

  List<Snippet> search(String query) => _repo.search(query);

  bool get isAtFreeLimit => _repo.isAtFreeLimit;
  int get count => _repo.count;
}
