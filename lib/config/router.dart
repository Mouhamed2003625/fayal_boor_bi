// ============================================================================
// FICHIER : lib/config/router.dart (ou similaire)
// ============================================================================
//
// Ce fichier configure la navigation de l'application avec GoRouter,
// et expose cette configuration sous forme d’un Provider Riverpod.
// Cela crée une architecture moderne, robuste, scalable et bien structurée.
//
// Concepts clés abordés :
//   - Provider (Riverpod)
//   - GoRouter (navigation déclarative)
//   - Définition des routes
//   - Navigation par chemins et par noms
//
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:weer_bi_dena/models/client_model.dart';
import 'package:weer_bi_dena/screens/clients/infos_client_screen.dart';
import 'package:weer_bi_dena/screens/dashboard_screen.dart';
import 'package:weer_bi_dena/screens/notifications/notifications_screen.dart';
import 'package:weer_bi_dena/screens/paiements/add_payment_screen.dart';
import 'package:weer_bi_dena/screens/paiements/payments_screen.dart';
import 'package:weer_bi_dena/screens/register_screen.dart';

// Importation de tous les écrans utilisés dans les routes de l'application.
import '../screens/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
// les ecrans de clients
import '../screens/clients/add_client_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/edit_client_screen.dart';


/// ===========================================================================
/// 1. Provider routerProvider
/// ===========================================================================
///
/// Ce Provider expose une instance de GoRouter.
/// Grâce à Riverpod, ce router pourra être récupéré depuis n’importe quel endroit
/// de l’application (par exemple dans MyApp).
///
/// Avantages d’utiliser Riverpod pour le router :
///   - centralisation de la configuration,
///   - lisibilité accrue,
///   - testabilité (le router peut être mocké ou remplacé),
///   - flexibilité (ex : navigation conditionnelle selon l'état d'authentification).
///
final routerProvider = Provider<GoRouter>((ref) {

  Client client;
  return GoRouter(

    // ------------------------------------------------------------------------
    // ROUTE INITIALE
    // ------------------------------------------------------------------------
    //
    // C’est l’écran affiché automatiquement lorsque l’application démarre.
    // Ici : l’utilisateur arrive d’abord sur la page de connexion.
    initialLocation: '/home',

    // ------------------------------------------------------------------------
    // DÉFINITION DE TOUTES LES ROUTES DE L'APPLICATION
    // ------------------------------------------------------------------------
    //
    // Chaque GoRoute représente un "écran" accessible via un chemin URL.
    // Structure générale :
    //    path   : l’adresse (ex: /home)
    //    name   : identifiant interne pratique pour naviguer par nom
    //    builder: retourne le widget à afficher
    //
    routes: [

      // ----------------------------------------------------------------------
      // ROUTE : Écran de connexion
      // ----------------------------------------------------------------------
      GoRoute(
        path: '/login',          // Chemin dans l'application
        name: 'login',           // Nom unique (plus pratique pour naviguer)
        builder: (context, state) => const LoginScreen(),
      ),

      // ----------------------------------------------------------------------
      // ROUTE : Écran d'accueil (liste des incidents)
      // ----------------------------------------------------------------------
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


      // ----------------------------------------------------------------------
      // ROUTE : Écran pour les clients
      // ----------------------------------------------------------------------
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

      GoRoute(path: '/infosclients',
      name: 'infosclients',
      builder: (context,state) {
        final client= state.extra as Client;
        return InfosClientScreen(client: client);
      }),

      GoRoute(path: '/editsclients',
          name: 'editsclients',
          builder: (context,state) {
            final client= state.extra as Client;
            return EditClientScreen(client: client);
          }),


      // ----------------------------------------------------------------------
      // ROUTE : Écran pour les payments
      // ----------------------------------------------------------------------

      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) => const PaymentsScreen(),
      ),



      GoRoute(path: '/ajoutpayement',
      name: 'ajoutpayement',
      builder: (context,state) {
        final client = state.extra as Client?;
        return AddPaymentScreen(client: client);
      }
      ),

      // ----------------------------------------------------------------------
      // ROUTE : Écran pour les notifications
      // ----------------------------------------------------------------------

      GoRoute(
        path: '/notification',
        name: 'notification',
        builder: (context, state) => const NotificationsScreen(),
      ),


    ],
  );
});