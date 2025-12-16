import 'package:flutter/material.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;

  void saveClient() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isSaving = false);

      print("Nouveau client ajouté : ");
      print("Nom : ${nameController.text}");
      print("Téléphone : ${phoneController.text}");
      print("Adresse : ${addressController.text}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Client enregistré avec succès")),
      );

      Navigator.pop(context); // Retour au dashboard
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un Client"),
        backgroundColor: const Color(0xFF0A4DA1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              // ICONE
              const Icon(Icons.person_add_alt_1,
                  size: 80, color: Color(0xFF0A4DA1)),
              const SizedBox(height: 20),

              // NOM
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom complet du client",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Entrez le nom du client" : null,
              ),
              const SizedBox(height: 20),

              // TELEPHONE
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Numéro de téléphone",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Entrez un numéro valide" : null,
              ),
              const SizedBox(height: 20),

              // ADRESSE
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "Adresse du client (optionnel)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 30),

              // BOUTON ENREGISTRER
              ElevatedButton(
                onPressed: isSaving ? null : saveClient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFFFF),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.blue)
                    : const Text("Enregistrer le client",
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
