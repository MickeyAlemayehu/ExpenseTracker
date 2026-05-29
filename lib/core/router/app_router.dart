import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/pin_lock_screen.dart';
import '../../features/auth/presentation/screens/pin_setup_screen.dart';
import '../../features/budget/presentation/screens/add_edit_budget_screen.dart';
import '../../features/budget/presentation/screens/budgets_screen.dart';
import '../../features/categories/presentation/screens/add_edit_category_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import '../../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Single GoRouter instance for the app. We avoid recreating it on settings /
/// auth changes — that would reset navigation state. Instead the router is
/// refreshed via a [ValueNotifier] whose value bumps when either dependency
/// changes; the redirect function reads current state via [ref.read].
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(authControllerProvider, (_, __) => refresh.value++)
    ..listen(settingsProvider, (_, __) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final settings = ref.read(settingsProvider);
      final loc = state.uri.path;

      const open = {'/splash', '/onboarding', '/lock', '/pin-setup'};
      if (open.contains(loc)) return null;

      if (!settings.onboardingComplete) return '/onboarding';
      if (auth.status == AuthStatus.needsSetup) return '/pin-setup';
      if (auth.status == AuthStatus.locked) return '/lock';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/lock',
        builder: (_, __) => const PinLockScreen(),
      ),
      GoRoute(
        path: '/pin-setup',
        builder: (_, __) => const PinSetupScreen(),
      ),

      // Modal-style routes shown without the bottom nav.
      GoRoute(
        path: '/transactions/new',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const AddEditTransactionScreen(),
      ),
      GoRoute(
        path: '/transactions/:id/edit',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => AddEditTransactionScreen(
          transactionId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/transactions/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            TransactionDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/categories/new',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const AddEditCategoryScreen(),
      ),
      GoRoute(
        path: '/categories/:id/edit',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => AddEditCategoryScreen(
          categoryId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/budgets/new',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const AddEditBudgetScreen(),
      ),
      GoRoute(
        path: '/budgets/:id/edit',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => AddEditBudgetScreen(
          budgetId: state.pathParameters['id'],
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/transactions',
              builder: (_, __) => const TransactionsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/analytics',
              builder: (_, __) => const AnalyticsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/budgets',
              builder: (_, __) => const BudgetsScreen(),
            ),
            GoRoute(
              path: '/categories',
              builder: (_, __) => const CategoriesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});
