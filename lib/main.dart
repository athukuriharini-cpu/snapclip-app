import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/models/snippet.dart';
import 'data/models/category.dart';
import 'data/services/revenuecat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(SnippetAdapter());
  Hive.registerAdapter(SnippetTypeAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  await Hive.openBox<Snippet>('snippets');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox('settings');

  // Initialize RevenueCat
  await RevenueCatService.initialize();

  runApp(
    const ProviderScope(
      child: SnapClipApp(),
    ),
  );
}
