import 'package:flutter/material.dart';

/// ===========================================================================
/// 1. DÉCLARATION D’UN WIDGET AVEC ÉTAT : StatefulWidget
/// ===========================================================================
///
/// L’écran de connexion est défini comme un StatefulWidget.
/// Pourquoi ?
/// - Un écran de connexion doit gérer :
///     * la saisie utilisateur,
///     * l’affichage d’erreurs,
///     * les états de chargement,
///     * la validation des champs.
/// - Ces comportements nécessitent un *état mutable*, manipulé via setState().
///
/// Donc même si l’écran est statique pour l’instant, il est pertinent de
/// préparer sa structure pour les évolutions futures.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// ===========================================================================
/// 2. CLASSE D’ÉTAT ASSOCIÉE : _LoginScreenState
/// ===========================================================================
///
/// Cette classe contient :
/// - les variables d’état (email, password, erreurs, chargement…),
/// - la logique fonctionnelle,
/// - la méthode build() qui génère l’interface.
///
/// Le préfixe "_" la rend privée au fichier.
class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // Scaffold structure une page complète Material Design :
    // - AppBar
    // - Body
    // - BottomNavigationBar
    // - FloatingActionButton
    // etc.
    return Scaffold(

      // ----------------------------------------------------------------------
      // 1. BARRE SUPÉRIEURE (AppBar)
      // ----------------------------------------------------------------------
      //
      // L’AppBar permet d’afficher un titre ou des actions (boutons…).
      appBar: AppBar(
        title: const Text("Connexion à DakarConnect"),
      ),

      // ----------------------------------------------------------------------
      // 2. CONTENU PRINCIPAL (BODY)
      // ----------------------------------------------------------------------
      //
      // Padding ajoute marges internes autour du contenu :
      // meilleure ergonomie, respect des guidelines UI.
      body: Padding(
        padding: const EdgeInsets.all(20.0),

        // Column : disposition des widgets en colonne verticale.
        child: Column(
          // Centre verticalement l’ensemble des widgets.
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // ================================================================
            // Champ de saisie : Adresse e-mail
            // ================================================================
            TextField(
              // Type spécifique de clavier (email) pour une meilleure UX.
              keyboardType: TextInputType.emailAddress,

              // decoration permet d’ajouter label, icône, bordure…
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',           // Texte d’aide
                border: OutlineInputBorder(),          // Bordure standard
                prefixIcon: Icon(Icons.email),         // Icône à gauche
              ),
            ),

            // Ajout d’un espace vertical de 20 pixels.
            const SizedBox(height: 20),

            // ================================================================
            // Champ de saisie : Mot de passe
            // ================================================================
            TextField(
              // Cache le texte saisi pour protéger le mot de passe.
              obscureText: true,

              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),          // Icône cadenas
              ),
            ),

            const SizedBox(height: 30),

            // ================================================================
            // Bouton de connexion
            // ================================================================
            ElevatedButton(
              // Fonction exécutée lors du clic.
              // Plus tard, vous y mettrez :
              //   - validation des champs
              //   - appel API / Firebase Auth
              //   - gestion des erreurs
              onPressed: () {
                print('Bouton de connexion cliqué !');
              },

              // Personnalisation du bouton.
              style: ElevatedButton.styleFrom(
                // Lui donner toute la largeur disponible
                minimumSize: const Size.fromHeight(50),
              ),

              // Texte affiché dans le bouton.
              child: const Text('Se Connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
