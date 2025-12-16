import 'package:flutter/material.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  void handleSubmit() {
    if (clientNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);

      print("Client : ${clientNameController.text}");
      print("Téléphone : ${phoneController.text}");
      print("Montant : ${amountController.text} FCFA");
      print("Description : ${descriptionController.text}");
      print("Date : ${DateTime.now()}");

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text("Ajouter une Dette"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.add_circle_outline,
                color: Colors.white, size: 80),
            const SizedBox(height: 25),

            // NOM CLIENT
            TextField(
              controller: clientNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle(
                  label: "Nom du client",
                  icon: Icons.person),
            ),
            const SizedBox(height: 20),

            // TELEPHONE
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle(
                  label: "Téléphone",
                  icon: Icons.phone),
            ),
            const SizedBox(height: 20),

            // MONTANT
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle(
                  label: "Montant (FCFA)",
                  icon: Icons.money),
            ),
            const SizedBox(height: 20),

            // DESCRIPTION
            TextField(
              controller: descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle(
                  label: "Description (optionnel)",
                  icon: Icons.description),
            ),
            const SizedBox(height: 35),

            // BOUTON AJOUTER
            ElevatedButton(
              onPressed: isLoading ? null : handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                minimumSize: const Size.fromHeight(55),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.blue)
                  : const Text(
                "Enregistrer la dette",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STYLE DES CHAMPS
  InputDecoration _inputStyle({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white70),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }
}
