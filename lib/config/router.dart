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
        return null; // Laisser l'écran actuel s'afficher
      }

      final isLoggedIn = authAsync.value != null;
      final location = state.matchedLocation;

      final isAuthPage = location == '/login' ||
          location == '/register' ||
          location == '/forgot-password';

      // 🔒 Pas connecté → rediriger vers la page d'accueil
      if (!isLoggedIn && !isAuthPage) {
        return '/home';
      }

      // ✅ Connecté → rediriger vers le dashboard
      if (isLoggedIn && (location == '/' || location == '/home' || isAuthPage)) {
        return '/dashboard';
      }

      return null; // Aucune redirection nécessaire
    },

    routes: [
      // 🏠 Page d'accueil (splash/landing)
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),

      // 🔐 Pages d'authentification
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
        path: '/forgotpassword',
        name: 'forgotpassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // 🏠 Pages principales
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

      // 👥 Gestion des clients
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
          try {
            final client = state.extra as Client?;
            if (client == null) {
              // Retour à la liste des clients avec message
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Client non spécifié'),
                    backgroundColor: Colors.orange,
                  ),
                );
              });
              return const ClientsScreen();
            }
            return InfosClientScreen(client: client);
          } catch (e) {
            // En cas d'erreur de cast
            return Scaffold(
              appBar: AppBar(title: const Text('Erreur')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 20),
                    const Text(
                      'Erreur de chargement',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => context.go('/clientScreen'),
                      child: const Text('Retour à la liste'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      GoRoute(
        path: '/editclient',
        name: 'editclient',
        builder: (context, state) {
          try {
            final client = state.extra as Client?;
            if (client == null) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Erreur'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/clientScreen'),
                  ),
                ),
                body: const Center(
                  child: Text('Client non spécifié pour édition'),
                ),
              );
            }
            return EditClientScreen(client: client);
          } catch (e) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 20),
                    const Text('Données client invalides'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.go('/clientScreen'),
                      child: const Text('Retour aux clients'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),

      // 💰 Gestion des paiements
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/ajoutpayement',
        name: 'ajoutpayement',
        builder: (context, state) {
          try {
            final client = state.extra as Client?;
            return AddPaymentScreen(client: client);
          } catch (e) {
            // Si erreur de cast, créer un nouvel écran sans client
            return const AddPaymentScreen(client: null);
          }
        },
      ),

      // 📋 Gestion des dettes
      GoRoute(
        path: '/debts',
        name: 'debts',
        builder: (context, state) => const DebtsScreen(),
      ),
      GoRoute(
        path: '/debt-details',
        name: 'details',
        builder: (context, state) {
          try {
            final debt = state.extra as Debt;
            return DebtDetailsScreen(debt: debt);
          } catch (e) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Erreur'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/debts'),
                ),
              ),
              body: const Center(
                child: Text('Dette non trouvée'),
              ),
            );
          }
        },
      ),
      GoRoute(
        path: '/editdebt',
        name: 'editdebt',
        builder: (context, state) {
          try {
            final debt = state.extra as Debt;
            return EditDebtScreen(debt: debt);
          } catch (e) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Erreur'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/debts'),
                ),
              ),
              body: const Center(
                child: Text('Impossible de modifier cette dette'),
              ),
            );
          }
        },
      ),
      GoRoute(
        path: '/ajoutdebt',
        name: 'ajoutdebt',
        builder: (context, state) => const AddDebtScreen(),
      ),

      // 🔔 Notifications
      GoRoute(
        path: '/notification',
        name: 'notification',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],

    // 🚨 Gestionnaire d'erreurs global
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              Text(
                'Erreur 404',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Page non trouvée: ${state.uri.path}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Tableau de bord'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/clientScreen'),
                    child: const Text('Clients'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/payment'),
                    child: const Text('Paiements'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },

    // 📝 Debug logging
    debugLogDiagnostics: true,
  );
});