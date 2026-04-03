import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/test/screens/test_screen.dart';
import '../features/results/screens/results_screen.dart';
import '../features/admin/screens/admin_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuth = auth.isAuthenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isAuth && !isAuthRoute) return AppRoutes.login;
      if (isAuth && isAuthRoute) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (ctx, state) => _fadePage(const LoginScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (ctx, state) => _fadePage(const RegisterScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        pageBuilder: (ctx, state) => _fadePage(const DashboardScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.test,
        pageBuilder: (ctx, state) {
          final testId = state.pathParameters['testId'] ?? '';
          final testName = state.extra as String? ?? '';
          return _fadePage(TestScreen(testId: testId, testName: testName), state);
        },
      ),
      GoRoute(
        path: AppRoutes.results,
        pageBuilder: (ctx, state) => _fadePage(const ResultsScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.adminPanel,
        redirect: (ctx, state) {
          final authState = ref.read(authProvider);
          return authState.isAdmin ? null : AppRoutes.dashboard;
        },
        pageBuilder: (ctx, state) => _fadePage(const AdminScreen(), state),
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

CustomTransitionPage<void> _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (ctx, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
