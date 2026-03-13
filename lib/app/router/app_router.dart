import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stably_app/features/alerts/presentation/alerts_page.dart';
import 'package:stably_app/features/discover/presentation/discover_page.dart';
import 'package:stably_app/features/home/presentation/home_page.dart';
import 'package:stably_app/features/settings/presentation/settings_page.dart';
import 'package:stably_app/features/stablecoins/presentation/stablecoin_detail_page.dart';
import 'package:stably_app/shared/widgets/app_shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _discoverNavigatorKey = GlobalKey<NavigatorState>();
final _alertsNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.home.path,
    routes: [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) =>
            AppShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _discoverNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoute.discover.path,
                name: AppRoute.discover.name,
                builder: (context, state) => const DiscoverPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _alertsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoute.alerts.path,
                name: AppRoute.alerts.name,
                builder: (context, state) => const AlertsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoute.settings.path,
        name: AppRoute.settings.name,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoute.stablecoinDetail.path,
        name: AppRoute.stablecoinDetail.name,
        builder: (context, state) => StablecoinDetailPage(
          stablecoinId: state.pathParameters['id'] ?? '',
          highlightedChain: state.uri.queryParameters['chain'],
        ),
      ),
    ],
  );
});

enum AppRoute {
  home('home', '/'),
  discover('discover', '/discover'),
  alerts('alerts', '/alerts'),
  settings('settings', '/settings'),
  stablecoinDetail('stablecoinDetail', '/stablecoins/:id');

  const AppRoute(this.name, this.path);

  final String name;
  final String path;
}
