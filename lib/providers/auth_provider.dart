// ============================================================================
// FICHIER : lib/providers/auth_provider.dart
// ============================================================================
//
// Ce fichier définit un **provider Riverpod extrêmement simple**, mais
// fondamental pour le fonctionnement de votre application.
//
// Il s’agit d’un *StateProvider<bool>* servant à indiquer si l’utilisateur est
// connecté (true) ou déconnecté (false).
//
// Même si ce code paraît très court, il pose les **fondations du système
// d’authentification réactif** dans l’ensemble de votre application.
//
// Ce fichier est un excellent support pédagogique pour comprendre :
//   - la notion d’état global,
//   - la différence entre un provider et un StateNotifier,
//   - comment un booléen peut piloter toute la navigation,
//   - pourquoi Riverpod est un outil puissant.
//
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// NOTE PÉDAGOGIQUE :
// L’import `legacy.dart` est une ancienne API de Riverpod.
// Dans une application moderne, on utilise uniquement flutter_riverpod.dart.
// Mais comme demandé, **on ne modifie pas le code fourni**.
// ============================================================================

/// ---------------------------------------------------------------------------
/// 1. Définition du provider : authStateProvider
/// ---------------------------------------------------------------------------
///
/// Un **StateProvider** est l’un des types de providers les plus simples dans
/// Riverpod. Il sert à stocker un petit état dynamique que l’on peut :
///   ✓ Lire
///   ✓ Modifier
///   ✓ Observer dans l’interface utilisateur
///
/// Pourquoi un booléen pour l’authentification ?
///
///   - true  → utilisateur connecté
///   - false → utilisateur déconnecté
///
/// C’est suffisant dans un premier prototype.
/// Ensuite, on pourra évoluer vers un modèle plus avancé
/// (ex : StreamProvider<User?>, StateNotifier, ou AuthController).
///
/// ---------------------------------------------------------------------------
/// FONCTIONNEMENT :
/// ---------------------------------------------------------------------------
///
/// Lorsqu’un widget exécute :
///     ref.read(authStateProvider.notifier).state = true;
///
/// → L’état global change
/// → Tous les widgets qui “watch” ce provider sont reconstruits
/// → GoRouter (si configuré pour écouter ce provider) applique automatiquement
///   les règles de redirection (login → home, home → login, etc.)
///
/// C’est la base du *routing conditionnel* dans une architecture moderne.
///
/// ---------------------------------------------------------------------------
///
final authStateProvider = StateProvider<bool>((ref) {
  // La valeur initiale de notre état.
  //
  // Au démarrage :
  //   - on considère que l’utilisateur n’est PAS connecté.
  //   - donc on renvoie false.
  //
  // Cela servira de point de départ pour le système d’authentification :
  // tant que cette valeur est false, GoRouter peut interdire l’accès
  // aux pages sécurisées comme /home ou /report.
  return false;
});