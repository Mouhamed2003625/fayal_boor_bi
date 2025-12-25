// ============================================================================
// FICHIER : lib/main.dart
// Version moderne avec Riverpod + GoRouter
// ============================================================================
//
// Point d’entrée de l’application Weer Bi Dena.
// - Riverpod : gestion d’état globale
// - GoRouter : navigation déclarative
// - MaterialApp.router : configuration moderne Flutter
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import de la configuration du routeur
import 'config/router.dart';

void main() {
  // ProviderScope est obligatoire pour utiliser Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ============================================================================
// MyApp devient un ConsumerWidget
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

      // Thème global de l'application
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
    );
  }
}
