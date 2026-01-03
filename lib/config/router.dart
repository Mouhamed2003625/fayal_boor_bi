import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../repositories/auth_repository.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
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
import '../models/client_model.dart';

/// 🔁 Rafraîchissement du router sur changement Auth
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // ⚡ Écoute l'état d'auth
  final authAsync = ref.watch(authStateChangesProvider);
  final authStream = ref.read(authRepositoryProvider).authStateChanges;

  final refreshListenable = GoRouterRefreshStream(authStream);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,

    redirect: (context, state) {
      // 🔄 Si on est encore en train de charger l'état Firebase
      if (authAsync.isLoading) return null; // laisse le SplashScreen s'afficher

      final isLoggedIn = authAsync.value != null;

      // Pages auth
      final onLoginPage = state.matchedLocation == '/login';
      final onRegisterPage = state.matchedLocation == '/register';
      final onForgotPage = state.matchedLocation == '/forgot-password';
      final onSplash = state.matchedLocation == '/';

      // Cas 1 : utilisateur non connecté → redirige vers login
      if (!isLoggedIn && !(onLoginPage || onRegisterPage || onForgotPage)) {
        return '/login';
      }

      // Cas 2 : utilisateur connecté → redirige vers home si on est sur splash ou login/register
      if (isLoggedIn && (onSplash || onLoginPage || onRegisterPage)) {
        return '/home';
      }

      // Cas 3 : rester sur la page actuelle
      return null;
    },

    routes: [
      // 🔵 Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // 🔐 Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // 🏠 App
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

      // 👥 Clients
      GoRoute(
        path: '/clientScreen',
        name: 'clientScreen',
        builder: (context, state) => const ClientsScreen(),
      ),
      GoRoute(
        path: '/addclient',
        name: 'addclient',
        builder: (context, state) => const AddClientScreen(),
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

      // 💰 Paiements
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/ajoutpayement',
        builder: (context, state) {
          final client = state.extra as Client?;
          return AddPaymentScreen(client: client);
        },
      ),

      // 🔔 Notifications
      GoRoute(
        path: '/notification',
        name: 'notification',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
