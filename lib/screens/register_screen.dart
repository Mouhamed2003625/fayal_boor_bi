import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isLoading = false;

  void handleRegister() {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Les mots de passe ne correspondent pas"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    // Simulation backend
    Future.delayed(const Duration(seconds: 2), () {
      print("Nom boutique : ${shopNameController.text}");
      print("Téléphone : ${phoneController.text}");
      print("Mot de passe : ${passwordController.text}");

      setState(() => isLoading = false);

      Navigator.pop(context); // Retour vers l'écran précédent
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700, // 🔵 Fond bleu
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text("Créer un Compte"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/login');
          } // Retour Home
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // LOGO
            const Icon(
              Icons.person_add,
              size: 90,
              color: Colors.white,
            ),
            const SizedBox(height: 20),

            // BOUTIQUE NAME
            _buildWhiteTextField(
              controller: shopNameController,
              label: "Nom de la boutique",
              icon: Icons.store,
            ),
            const SizedBox(height: 20),

            // PHONE NUMBER
            _buildWhiteTextField(
              controller: phoneController,
              label: "Numéro de téléphone",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // PASSWORD
            _buildWhiteTextField(
              controller: passwordController,
              label: "Mot de passe",
              icon: Icons.lock,
              obscure: true,
            ),
            const SizedBox(height: 20),

            // CONFIRM PASSWORD
            _buildWhiteTextField(
              controller: confirmPasswordController,
              label: "Confirmer mot de passe",
              icon: Icons.lock_outline,
              obscure: true,
            ),
            const SizedBox(height: 30),

            // REGISTER BUTTON
            ElevatedButton(
              onPressed: isLoading ? null : handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                minimumSize: const Size.fromHeight(55),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.blue)
                  : const Text("Créer mon compte"),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET RÉUTILISABLE POUR LES CHAMPS BLANCS ---
  Widget _buildWhiteTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
