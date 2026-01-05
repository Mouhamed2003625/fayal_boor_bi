// ============================================================================
// FICHIER : lib/main.dart
// Version moderne avec Riverpod + GoRouter + Firebase
// ============================================================================
//
// Point d’entrée de l’application Weer Bi Dena.
// - Riverpod : gestion d’état globale
// - GoRouter : navigation déclarative
// - Firebase : backend, Auth, Firestore
// - MaterialApp.router : configuration moderne Flutter
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1️⃣ Import Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // généré par flutterfire configure

// 2️⃣ Import de la configuration du routeur
import 'config/router.dart';

void main() async {
  // On rend main async car Firebase doit être initialisé avant runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ProviderScope obligatoire pour Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ============================================================================
// MyApp devient un ConsumerWidget pour accéder aux providers
// ============================================================================
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lecture du provider GoRouter
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // Configuration du routeur
      routerConfig: router,

      // Thème global
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
    );
  }
}
