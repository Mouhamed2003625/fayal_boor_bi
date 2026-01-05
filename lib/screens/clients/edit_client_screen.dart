import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/client_model.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController amountDueController;
  late TextEditingController amountPaidController;
  late TextEditingController productController;
  late TextEditingController quantityController;
  late TextEditingController paymentDateController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.client.name);
    phoneController = TextEditingController(text: widget.client.phone);
    addressController = TextEditingController(text: widget.client.address);
    amountDueController =
        TextEditingController(text: widget.client.amountDue.toString());
    amountPaidController =
        TextEditingController(text: widget.client.amountPaid.toString());
    productController =
        TextEditingController(text: widget.client.product.toString());
    quantityController =
        TextEditingController(text: widget.client.quantity.toString());
    paymentDateController =
        TextEditingController(text: widget.client.paymentDate.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    amountDueController.dispose();
    amountPaidController.dispose();
    productController.dispose();
    quantityController.dispose();
    paymentDateController.dispose();
    super.dispose();
  }

  void saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => isSaving = false);

      // ✨ Mise à jour du client
      widget.client.name = nameController.text;
      widget.client.phone = phoneController.text;
      widget.client.address = addressController.text;
      widget.client.amountDue = double.tryParse(amountDueController.text) ?? 0;
      widget.client.amountPaid = double.tryParse(amountPaidController.text) ?? 0;
      widget.client.product = productController.text;
      widget.client.quantity = quantityController.text;
      widget.client.paymentDate =
          DateTime.tryParse(paymentDateController.text);

      Navigator.pop(context, widget.client);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Client modifié avec succès !")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            final client = widget.client; // s'assurer que c'est bien le client actuel
            context.goNamed(
              'infosclients',
              extra: client,
            );
          },
        ),

        title: const Text(
          "Modifier le client",
          style: TextStyle(color: Colors.white),
        ),
      ),

      // ================= BODY =================
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
              const SizedBox(height: 60),

              // -------- HEADER --------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Modifier ${widget.client.name}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------- FORM CONTENT --------
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
                        const SizedBox(height: 20),

                        // NOM
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: "Nom complet",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? "Entrez le nom"
                              : null,
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
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? "Entrez un numéro"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // ADRESSE
                        TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            labelText: "Adresse",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // MONTANT DÛ
                        TextFormField(
                          controller: amountDueController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Montant dû (FCFA)",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.money),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? "Entrez un montant"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // MONTANT PAYÉ
                        TextFormField(
                          controller: amountPaidController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Montant payé (FCFA)",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.money),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // PRODUIT
                        TextFormField(
                          controller: productController,
                          decoration: const InputDecoration(
                            labelText: "Produit",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.icecream_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // QUANTITÉ
                        TextFormField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: "Quantité",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.confirmation_num),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // DATE DE PAIEMENT
                        TextFormField(
                          controller: paymentDateController,
                          decoration: const InputDecoration(
                            labelText: "Date de paiement",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // BOUTON SAUVEGARDER
                        ElevatedButton(
                          onPressed: isSaving ? null : saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B2FF7),
                            minimumSize: const Size.fromHeight(50),
                            foregroundColor: Colors.white,
                          ),
                          child: isSaving
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text("Sauvegarder"),
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
