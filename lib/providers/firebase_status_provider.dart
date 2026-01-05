// ============================================================================
// FICHIER : lib/providers/firebase_status_provider.dart
// ============================================================================
//
// Ce fichier définit un **FutureProvider<bool>** qui permet de vérifier :
//
//   1) si Firebase est correctement initialisé,
//   2) si un utilisateur est déjà connecté dans Firebase Authentication.
//
// Il s’agit d’un outil pédagogique très utile pour :
//   - afficher un SplashScreen conditionnel,
//   - rediriger automatiquement selon la session,
//   - vérifier l’état initial de l’application,
//   - éviter les erreurs quand Firebase n’est pas encore prêt.
//
// Ce code constitue un excellent exemple pour enseigner :
//   - le rôle d’un FutureProvider,
//   - la gestion de Firebase.app() et Firebase.initializeApp(),
//   - la lecture de FirebaseAuth.instance.currentUser,
//   - les bonnes pratiques d’initialisation dans Flutter.
//
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


/// ===========================================================================
/// firebaseStatusProvider : FutureProvider<bool>
/// ===========================================================================
///
/// Ce provider exécute du code **asynchrone** pour vérifier deux éléments :
///
///   1. Firebase est-il correctement initialisé ?
///      (important lors du démarrage de l’app, sur iOS/Android/Web)
///
///   2. Un utilisateur est-il déjà connecté dans Firebase ?
///      (par exemple si la session persiste après redémarrage)
//
//
/// Pourquoi un FutureProvider ?
/// ----------------------------
/// - FutureProvider est conçu pour exposer le résultat D’UNE OPÉRATION ASYNCHRONE.
/// - Riverpod reconstruira les widgets qui l'écoutent une fois le futur complété.
/// - C’est parfait pour un écran Splash ou une validation initiale.
//
/// Valeur retournée :
///   true  → Firebase est prêt **et** un utilisateur est connecté
///   false → Firebase est prêt mais **pas d’utilisateur connecté**
///
/// ===========================================================================

final firebaseStatusProvider = FutureProvider<bool>((ref) async {
  // --------------------------------------------------------------------------
  // Vérification 1 : Firebase est-il déjà initialisé ?
  // --------------------------------------------------------------------------
  //
  // Firebase.app() :
  //   - Retourne l’instance Firebase existante,
  //   - Lance une exception si Firebase N’EST PAS initialisé.
  //
  // Grâce au try/catch :
  //   - Si aucune erreur → Firebase est prêt
  //   - Si erreur → on initialise Firebase manuellement
  try {
    final _ = Firebase.app(); // simple vérification sans utilisation réelle
  } catch (_) {
    // Si Firebase n’a pas encore été initialisé,
    // on l’initialise ici de manière sécurisée.
    await Firebase.initializeApp();
  }

  // --------------------------------------------------------------------------
  // Vérification 2 : Un utilisateur Firebase est-il déjà connecté ?
  // --------------------------------------------------------------------------
  //
  // FirebaseAuth.instance.currentUser :
  //   - null  → aucun utilisateur connecté
  //   - User  → utilisateur déjà en session
  //
  // La valeur booléenne renvoyée sert à déterminer
  // l'état de session pour le premier rendu de l'application.
  return FirebaseAuth.instance.currentUser != null;
});