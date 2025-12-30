import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../repositories/auth_repository.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/clients/add_client_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/infos_client_screen.dart';
import '../screens/clients/edit_client_screen.dart';
import '../screens/paiements/add_payment_screen.dart';
import '../screens/paiements/payments_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import 'package:weer_bi_dena/models/client_model.dart';

/// -----------------------
/// GoRouterRefreshStream
/// -----------------------
/// Permet à GoRouter de se rafraîchir à chaque changement
/// du stream Firebase Auth (login / logout)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// -----------------------
/// Provider du router
/// -----------------------
final routerProvider = Provider<GoRouter>((ref) {
  // 1. État d'auth Firebase
  final authAsync = ref.watch(authStateChangesProvider);
  final authStream = ref.read(authRepositoryProvider).authStateChanges;

  // 2. RefreshListenable pour GoRouter
  final refreshListenable = GoRouterRefreshStream(authStream);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      if (authAsync.isLoading) return null;
      if (authAsync.hasError) return null;

      final isLoggedIn = authAsync.value != null;
      final isAtLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isAtLogin) return '/login';
      if (isLoggedIn && isAtLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Clients
      GoRoute(
        path: '/addclient',
        name: 'addclient',
        builder: (context, state) => const AddClientScreen(),
      ),
      GoRoute(
        path: '/clientScreen',
        name: 'clientScreen',
        builder: (context, state) => const ClientsScreen(),
      ),
      GoRoute(
        path: '/infosclients',
        name: 'infosclients',
        builder: (context, state) {
          final client = state.extra as Client;
          return InfosClientScreen(client: client);
        },
      ),
      GoRoute(
        path: '/editsclients',
        name: 'editsclients',
        builder: (context, state) {
          final client = state.extra as Client;
          return EditClientScreen(client: client);
        },
      ),
      // Paiements
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/ajoutpayement',
        name: 'ajoutpayement',
        builder: (context, state) {
          final client = state.extra as Client?;
          return AddPaymentScreen(client: client);
        },
      ),
      // Notifications
      GoRoute(
        path: '/notification',
        name: 'notification',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
