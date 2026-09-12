import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/add_snippet/add_snippet_screen.dart';
import '../../presentation/screens/snippet_detail/snippet_detail_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/categories/categories_screen.dart';
import '../../presentation/screens/paywall/paywall_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../data/models/snippet.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) {
          final snippet = state.extra as Snippet?;
          return AddSnippetScreen(snippet: snippet);
        },
      ),
      GoRoute(
        path: '/snippet/:id',
        builder: (context, state) {
          final snippet = state.extra as Snippet;
          return SnippetDetailScreen(snippet: snippet);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) {
          final reason = state.extra as String? ?? 'Upgrade to Pro';
          return PaywallScreen(reason: reason);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
