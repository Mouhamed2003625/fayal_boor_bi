import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ----------------- AuthRepository -----------------
/// Cette classe gère toutes les opérations liées à l'authentification
/// (inscription, connexion, déconnexion, réinitialisation mot de passe)
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream pour GoRouter et widgets
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Inscription
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Erreur d\'inscription: ${e.message}');
    }
  }

  /// Connexion
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception('Erreur de connexion: ${e.message}');
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Réinitialisation mot de passe
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Erreur lors de la réinitialisation : ${e.message}');
    }
  }
}

/// ----------------- Providers Riverpod -----------------

/// Fournit une instance unique d'AuthRepository dans toute l'application
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Fournit le Stream<User?> pour écouter les changements d'état de connexion
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});
