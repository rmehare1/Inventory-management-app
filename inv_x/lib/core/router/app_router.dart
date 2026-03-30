import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/inventory/presentation/screens/inventory_list_screen.dart';
import '../../features/inventory/presentation/screens/add_product_screen.dart';
import '../../features/inventory/presentation/screens/product_detail_screen.dart';
import '../../features/inventory/presentation/screens/category_screen.dart';
import '../../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../../features/reports/presentation/screens/reports_hub_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_list_screen.dart';
import '../../features/orders/presentation/screens/orders_list_screen.dart';
import '../../features/ai_forecast/presentation/screens/forecast_screen.dart';
import '../../features/ai_anomaly/presentation/screens/anomaly_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../theme/app_colors.dart';


part 'shell_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({required bool isFirstLaunch}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: isFirstLaunch ? '/splash' : '/dashboard',
    routes: [
      // -- Splash & Onboarding (full-screen, no shell) --
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),

      // -- Main Shell with Bottom Navigation --
      ShellRoute(
        builder: (_, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/inventory',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: InventoryListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, _) => const AddProductScreen(),
              ),
              GoRoute(
                path: ':productId',
                builder: (_, state) => ProductDetailScreen(
                  productId: state.pathParameters['productId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/ai-chat',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: AiChatScreen(),
            ),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: ReportsHubScreen(),
            ),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // -- Full-screen routes (outside shell) --
      GoRoute(
        path: '/categories',
        builder: (_, _) => const CategoryScreen(),
      ),
      GoRoute(
        path: '/suppliers',
        builder: (_, _) => const SupplierListScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, _) => const OrdersListScreen(),
      ),
      GoRoute(
        path: '/forecast',
        builder: (_, _) => const ForecastScreen(),
      ),
      GoRoute(
        path: '/anomalies',
        builder: (_, _) => const AnomalyScreen(),
      ),
    ],
  );
}
