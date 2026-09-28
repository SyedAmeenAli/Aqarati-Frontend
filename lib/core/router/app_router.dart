import 'package:go_router/go_router.dart';
import '../../features/business/business_profile_screen.dart';
import '../../features/business/professional_discovery_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/messages/messages_screen.dart';
import '../../features/onboarding/onboarding_flow.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/property/property_detail_screen.dart';
import '../../data/models/enums.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/search/search_results_screen.dart';
import '../../features/search/search_screen.dart';
import 'app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingFlow()),
    GoRoute(path: '/saved', builder: (context, state) => const SavedScreen()),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final typeParam = state.uri.queryParameters['type'];
        PropertyType? propertyType;
        if (typeParam != null) {
          for (final t in PropertyType.values) {
            if (t.name == typeParam) propertyType = t;
          }
        }
        return SearchResultsScreen(
          initialQuery: state.uri.queryParameters['q'],
          initialPropertyType: propertyType,
        );
      },
    ),
    GoRoute(path: '/search/start', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/property/:id',
      builder: (context, state) => PropertyDetailScreen(propertyId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/professionals',
      builder: (context, state) {
        final categoryParam = state.uri.queryParameters['category'];
        BusinessCategory? category;
        if (categoryParam != null) {
          for (final c in BusinessCategory.values) {
            if (c.name == categoryParam) category = c;
          }
        }
        return ProfessionalDiscoveryScreen(initialCategory: category);
      },
    ),
    GoRoute(
      path: '/business/:id',
      builder: (context, state) => BusinessProfileScreen(businessId: state.pathParameters['id']!),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
        GoRoute(path: '/messages', builder: (context, state) => const MessagesScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
  ],
);
