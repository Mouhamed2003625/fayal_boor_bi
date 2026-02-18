import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/debt_model.dart';
import '../../models/client_model.dart';
import '../../repositories/auth_repository.dart';

import '../../screens/dettes/debt_details_screen.dart';
import '../../screens/dettes/debts_screen.dart';
import '../../screens/dettes/edit_debt_screen.dart';
import '../../screens/dettes/add_debt_screen.dart';

import '../../screens/clients/clients_screen.dart';
import '../../screens/clients/add_client_screen.dart';
import '../../screens/clients/infos_client_screen.dart';
import '../../screens/clients/edit_client_screen.dart';

import '../../screens/paiements/payments_screen.dart';
import '../../screens/paiements/add_payment_screen.dart';

import '../../screens/app_screens/login_screen.dart';
import '../../screens/app_screens/register_screen.dart';
import '../../screens/app_screens/forgot_password_screen.dart';
import '../../screens/app_screens/home_screen.dart';
import '../../screens/app_screens/dashboard_screen.dart';

/// 🔁 Permet à GoRouter de se rafraîchir quand Firebase Auth change
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateChangesProvider);
  final authStream = ref.read(authRepositoryProvider).authStateChanges;
  final refreshListenable = GoRouterRefreshStream(authStream);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/',

    refreshListenable: refreshListenable,

    redirect: (context, state) {
      if (authAsync.isLoading) return null;

      final isLoggedIn = authAsync.value != null;
      final location = state.matchedLocation;
      final isAuthPage = location == '/login' || location == '/register' || location == '/forgotpassword';

      if (!isLoggedIn && !isAuthPage) return '/home';
      if (isLoggedIn && (location == '/' || location == '/home' || isAuthPage)) return '/dashboard';

      return null;
    },

    routes: [
      // 🏠 Pages d'accueil et splash
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/dashboard', name: 'dashboard', builder: (context, state) => const DashboardScreen()),

      // 🔐 Auth
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgotpassword', name: 'forgotpassword', builder: (context, state) => const ForgotPasswordScreen()),

      // 👥 Clients
      GoRoute(path: '/clientScreen', name: 'clientScreen', builder: (context, state) => const ClientsScreen()),
      GoRoute(path: '/addclient', name: 'addclient', builder: (context, state) => const AddClientScreen()),
      GoRoute(
        path: '/infosclients',
        name: 'infosclients',
        builder: (context, state) {
          final client = state.extra as Client?;
          if (client == null) return const ClientsScreen();
          return InfosClientScreen(client: client);
        },
      ),
      GoRoute(
        path: '/editclient',
        name: 'editclient',
        builder: (context, state) {
          final client = state.extra as Client?;
          if (client == null) return const ClientsScreen();
          return EditClientScreen(client: client);
        },
      ),

      // 📋 Dettes
      GoRoute(path: '/debts', name: 'debts', builder: (context, state) => const DebtsScreen()),
      GoRoute(
        path: '/debtdetails/:id',
        name: 'details',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final debtId = int.tryParse(idStr ?? '');

          if (debtId == null) {
            return const DebtsScreen();
          }

          return DebtDetailsScreen(debtId: debtId);
        },
      ),

      GoRoute(
        path: '/editdebt',
        name: 'editdebt',
        builder: (context, state) {
          final debt = state.extra as Debt?;
          if (debt == null) return const DebtsScreen();
          return EditDebtScreen(debt: debt);
        },
      ),
      GoRoute(path: '/ajoutdebt', name: 'ajoutdebt', builder: (context, state) => const AddDebtScreen()),

      // 💰 Paiements
      // 💰 Paiements

      GoRoute(
        path: '/payments',
        name: 'payments',
        builder: (context, state) => const PaymentsScreen()),

      GoRoute(
        path: '/addpayment/:id',
        name: 'addPayment',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final debtId = int.tryParse(idStr ?? '');

          if (debtId == null) {
            return const DebtsScreen();
          }

          return AddPaymentScreen(debtId: debtId);
        },
      ),

    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text('Erreur 404', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text('Page non trouvée: ${state.uri.path}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 30),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(onPressed: () => context.go('/dashboard'), child: const Text('Tableau de bord')),
                OutlinedButton(onPressed: () => context.go('/clientScreen'), child: const Text('Clients')),
              ],
            ),
          ],
        ),
      ),
    ),

    debugLogDiagnostics: true,
  );
});
