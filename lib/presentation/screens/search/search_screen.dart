import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/snippet.dart';
import '../../providers/snippets_provider.dart';
import '../../widgets/snippet_card.dart';
import '../../widgets/empty_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Snippet> _searchResults = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    final results = ref.read(snippetsProvider.notifier).search(query.trim());
    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by title, text, or #tags...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: !_hasSearched
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, size: 64, color: AppColors.onSurfaceVariant),
                  SizedBox(height: 16),
                  Text(
                    'Search anything in your vault',
                    style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : _searchResults.isEmpty
              ? const EmptyStateWidget(
                  title: 'No results found',
                  description: 'Try adjusting your search terms or search by a specific tag.',
                  icon: '🔍',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return SnippetCard(snippet: _searchResults[index]);
                  },
                ),
    );
  }
}
