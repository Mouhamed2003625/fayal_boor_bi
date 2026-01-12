import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/debt_model.dart';
import '../repositories/auth_repository.dart';
import '../screens/dettes/debt_details_screen.dart';
import '../screens/dettes/debts_screen.dart';
import '../screens/dettes/edit_debt_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/dettes/add_debt_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/add_client_screen.dart';
import '../screens/clients/infos_client_screen.dart';
import '../screens/clients/edit_client_screen.dart';
import '../screens/paiements/payments_screen.dart';
import '../screens/paiements/add_payment_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../models/client_model.dart';

/// 🔁 Permet à GoRouter de se rafraîchir quand Firebase Auth change
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // 🔥 État d’auth Firebase
  final authAsync = ref.watch(authStateChangesProvider);
  final authStream =
      ref.read(authRepositoryProvider).authStateChanges;

  final refreshListenable = GoRouterRefreshStream(authStream);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/',

    refreshListenable: refreshListenable,

    redirect: (context, state) {
      // ⏳ Firebase pas encore prêt
      if (authAsync.isLoading) {
        return '/';
      }

      final isLoggedIn = authAsync.value != null;
      final location = state.matchedLocation;

      final isAuthPage = location == '/login' ||
          location == '/register' ||
          location == '/forgot-password';

      // 🔒 Pas connecté → pages auth
      if (!isLoggedIn && !isAuthPage) {
        return '/home';
      }

      // ✅ Connecté → home
      if (isLoggedIn && (location == '/' || isAuthPage)) {
        return '/home';
      }

      return null;
    },

    routes: [
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
    builder: (context, state) => const NotificationsScreen(),),

    GoRoute(
    path: '/debts',
    name:'debts',
    builder: (_, __) => const DebtsScreen(),
    ),

      GoRoute(
        path: '/debt-details',
        name: 'details',
        builder: (_, state) =>
            DebtDetailsScreen(debt: state.extra as Debt),
      ),

      GoRoute(
        path: '/editdebt',
        builder: (context, state) {
          final debt = state.extra as Debt;
          return EditDebtScreen(debt: debt);
        },
      ),

      GoRoute(
        path: '/ajoutdebt',
        name: 'ajoutdebt',
        builder: (context, state) => const AddDebtScreen(),
      ),
    ],
  );
});
