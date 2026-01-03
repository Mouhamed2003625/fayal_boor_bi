import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final TextEditingController amountDueController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController amountPaidController = TextEditingController();

  DateTime? paymentDate;

  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;

  Future<void> pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() => paymentDate = date);
    }
  }

  void saveClient() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isSaving = false);

      print("====== NOUVEAU CLIENT ======");
      print("Nom : ${nameController.text}");
      print("Téléphone : ${phoneController.text}");
      print("Adresse : ${addressController.text}");
      print("Produit : ${productController.text}");
      print("Montant à payer : ${amountDueController.text}");
      print("Quantité : ${quantityController.text}");
      print("Montant versé : ${amountPaidController.text}");
      print("Date versement : $paymentDate");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Client enregistré avec succès")),
      );

      context.go('/clientScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= BODY AVEC FOND GRADIENT =================
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7B2FF7),
              Color(0xFF9F44D3),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ================= APP BAR PERSONNALISÉ =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        context.go('/clientScreen');
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Ajouter un Client",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= FORMULAIRE =================
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        const SizedBox(height: 10),
                        const Icon(Icons.person_add_alt_1,
                            size: 80, color: Color(0xFF7B2FF7)),
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
                        const SizedBox(height: 16),

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
                        const SizedBox(height: 16),

                        // ADRESSE
                        TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            labelText: "Adresse du client",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // PRODUIT
                        TextFormField(
                          controller: productController,
                          decoration: const InputDecoration(
                            labelText: "Nom du produit",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shopping_cart),
                          ),
                          validator: (v) =>
                          v == null || v.isEmpty ? "Entrez le nom du produit" : null,
                        ),
                        const SizedBox(height: 16),

                        // QUANTITE
                        TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Quantité",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          validator: (v) =>
                          v == null || v.isEmpty ? "Entrez une quantité" : null,
                        ),
                        const SizedBox(height: 16),

                        // MONTANT A PAYER
                        TextFormField(
                          controller: amountDueController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Montant à payer (FCFA)",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          validator: (v) =>
                          v == null || v.isEmpty ? "Entrez un montant" : null,
                        ),
                        const SizedBox(height: 16),

                        // MONTANT VERSE
                        TextFormField(
                          controller: amountPaidController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Montant versé (FCFA)",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.payments),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // DATE DE VERSEMENT
                        InkWell(
                          onTap: pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Date de versement",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.date_range),
                            ),
                            child: Text(
                              paymentDate == null
                                  ? "Sélectionner une date"
                                  : "${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // BOUTON ENREGISTRER
                        ElevatedButton(
                          onPressed: isSaving ? null : saveClient,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B2FF7),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Enregistrer le client",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
