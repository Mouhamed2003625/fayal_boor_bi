import 'package:flutter/material.dart';
import 'package:weer_bi_dena/screens/home_screen.dart'; // <-- important si tu veux éventuellement utiliser Navigator.push

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void handleLogin() {
    setState(() => isLoading = true);

    // Simulation d’un traitement (API ou Firebase)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
      print("Téléphone : ${phoneController.text}");
      print("Mot de passe : ${passwordController.text}");
      // TODO: Navigate to dashboard
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700, // 🔵 Fond bleu
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text("Connexion"),

        // 🔙 BOUTON DE RETOUR
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Retour à HomeScreen
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO
            const Icon(
              Icons.storefront,
              size: 90,
              color: Colors.white,
            ),
            const SizedBox(height: 25),

            // PHONE FIELD
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Numéro de téléphone",
                labelStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.phone, color: Colors.white),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // PASSWORD FIELD
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Mot de passe",
                labelStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.lock, color: Colors.white),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // LOGIN BUTTON
            ElevatedButton(
              onPressed: isLoading ? null : handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.blue)
                  : const Text("Se connecter"),
            ),
          ],
        ),
      ),
    );
  }
}
