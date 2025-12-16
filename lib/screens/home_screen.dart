// ============================================================================
// FICHIER : lib/screens/home_screen.dart
// ============================================================================
//
// Page d’accueil avec background bleu + animations.
// ============================================================================

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ------------------------------------------------------------------
        // 🔵 BACKGROUND BLEU (DÉGRADÉ)
        // ------------------------------------------------------------------
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A4DA1), // Bleu foncé
              Color(0xFF1976D2), // Bleu moyen
              Color(0xFF63A4FF), // Bleu clair
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ------------------------------------------------------------------
                  // LOGO
                  // ------------------------------------------------------------------
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFF0A4DA1),
                      size: 70,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ------------------------------------------------------------------
                  // TITRE + DESCRIPTION
                  // ------------------------------------------------------------------
                  const Text(
                    "Gestion des Dettes",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "Suivez, organisez et gérez facilement les dettes de vos clients.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 45),

                  // ------------------------------------------------------------------
                  // BOUTON : SE CONNECTER
                  // ------------------------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print("Naviguer vers connexion");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade900,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ------------------------------------------------------------------
                  // BOUTON : CRÉER UN COMPTE
                  // ------------------------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        print("Naviguer vers création de compte");
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(55),
                        side: const BorderSide(color: Colors.white, width: 2),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        "Créer un compte",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
