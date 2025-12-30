// ============================================================================
// FICHIER : lib/repositories/auth_repository.dart  (ou lib/providers/auth_repository.dart)
// ============================================================================
//
// Ce fichier rassemble toute la logique d’authentification de DakarConnect.
// C’est une implémentation propre, claire et professionnelle d’un pont entre :
//
//   • Firebase Authentication → création, connexion, déconnexion,
//   • Firebase Firestore → stockage des données utilisateur,
//   • Riverpod → mise à disposition de ces services dans toute l’app.
//
// Ce fichier constitue un support de cours idéal pour montrer :
//   • la séparation logique UI / Repository,
//   • comment encapsuler Firebase proprement,
//   • comment exposer des Streams,
//   • comment utiliser Riverpod pour partager un service dans toute l’app,
//   • comment gérer les erreurs (FirebaseAuthException).
//
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// ============================================================================
// AuthRepository — couche d’accès aux services Firebase
// ============================================================================
//
// Cette classe regroupe TOUTES les opérations liées à l’authentification.
// Elle agit comme un "service" ou un "repository" dans une architecture propre.
//
// Avantages pédagogiques :
//   - éviter de mettre du code Firebase dans les widgets,
//   - rendre l’application testable,
//   - rendre le code plus clair et structuré,
//   - permettre d’évoluer facilement (API, Firestore, changement de backend).
//
class AuthRepository {
  // FirebaseAuth et FirebaseFirestore sont des SINGLETONS :
  // on obtient toujours la même instance via .instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --------------------------------------------------------------------------
  // STREAM D’AUTHENTIFICATION  (authStateChanges)
  // --------------------------------------------------------------------------
  //
  // Retourne un Stream<User?> qui envoie un événement A CHAQUE changement
  // d'état de connexion :
  //   - connexion réussie,
  //   - déconnexion,
  //   - expiration de session,
  //   - ouverture de l’app avec session active.
  //
  // Très puissant car il permet à GoRouter / Riverpod d’adapter automatiquement
  // la navigation selon l'état de l'utilisateur.
  Stream<User?> get authStateChanges => _auth.authStateChanges();


  // --------------------------------------------------------------------------
  // MÉTHODE : signUp (inscription)
  // --------------------------------------------------------------------------
  //
  // Crée un utilisateur avec email + mot de passe, puis enregistre
  // ses données dans Firestore.
  //
  // Roles pédagogiques :
  //   - montrer comment chaîner FirebaseAuth + Firestore,
  //   - comprendre l’importance d’enregistrer des infos supplémentaires
  //     (nom complet, date d’inscription),
  //   - gérer les exceptions de manière propre.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // 1. Création de l’utilisateur via Firebase Authentication.
      //
      // Cette méthode crée l’utilisateur dans l’écosystème Firebase :
      //   - gestion du mot de passe,
      //   - sécurité,
      //   - liens de vérification si activés.
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // userCredential contient un UserCredential :
      //   - userCredential.user → l’utilisateur créé,
      //   - userCredential.additionalUserInfo → infos supplémentaires.
      final User? user = userCredential.user;

      // 2. Si la création est réussie (user != null),
      //    on crée son “profil” dans Firestore :
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      // Gestion propre des erreurs Firebase :
      // exemples :
      //   - email déjà utilisé,
      //   - mot de passe faible,
      //   - format email invalide.
      throw Exception('Erreur d\'inscription: ${e.message}');
    }
  }


  // --------------------------------------------------------------------------
  // MÉTHODE : signIn (connexion)
  // --------------------------------------------------------------------------
  //
  // Connecte un utilisateur avec email + mot de passe.
  //
  // Si la connexion réussit → l état authStateChanges émet un nouvel événement,
  // ce qui déclenche la redirection automatique via GoRouter.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Exemple d’erreurs :
      //   - mauvais mot de passe,
      //   - utilisateur inexistant,
      //   - trop de tentatives.
      throw Exception('Erreur de connexion: ${e.message}');
    }
  }


  // --------------------------------------------------------------------------
  // MÉTHODE : signOut (déconnexion)
  // --------------------------------------------------------------------------
  //
  // Déconnecte l’utilisateur.
  //
  // authStateChanges émettra automatiquement null,
  // ce qui déclenchera la redirection vers /login.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}


// ============================================================================
// PROVIDERS RIVERPOD
// ============================================================================

/// Provider pour rendre notre AuthRepository accessible dans toute l'app.
///
/// Ici, AuthRepository est instancié UNE SEULE FOIS.
/// Tous les widgets qui en ont besoin font :
///
///    final repo = ref.watch(authRepositoryProvider);
///
/// Cela permet une vraie architecture en couches.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});


/// StreamProvider qui écoute authStateChanges.
///
/// Ce StreamProvider expose la valeur User? en temps réel.
/// Les widgets peuvent réagir automatiquement, par exemple :
///
///    final user = ref.watch(authStateChangesProvider).value;
///
/// Certains écrans peuvent s’afficher différemment selon user != null.
///
/// GoRouter aussi peut l’utiliser pour protéger des routes.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  // On lit le repository (grâce au provider précédent)
  final authRepository = ref.watch(authRepositoryProvider);

  // On expose son stream authStateChanges
  return authRepository.authStateChanges;
});