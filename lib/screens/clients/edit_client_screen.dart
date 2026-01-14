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

  DateTime? paymentDate;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.client.name);
    phoneController = TextEditingController(text: widget.client.phone);
    addressController = TextEditingController(text: widget.client.address);
    amountDueController = TextEditingController(
        text: widget.client.amountDue?.toString() ?? ''
    );
    amountPaidController = TextEditingController(
        text: widget.client.amountPaid?.toString() ?? ''
    );
    productController = TextEditingController(text: widget.client.product);
    quantityController = TextEditingController(text: widget.client.quantity);

    // Initialiser la date de paiement si disponible
    if (widget.client.paymentDate != null) {
      paymentDate = widget.client.paymentDate!;
    }
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
    super.dispose();
  }

  Future<void> pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: paymentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => paymentDate = date);
    }
  }

  void saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => isSaving = false);

      // Mise à jour du client
      widget.client.name = nameController.text;
      widget.client.phone = phoneController.text;
      widget.client.address = addressController.text;
      widget.client.amountDue = double.tryParse(amountDueController.text);
      widget.client.amountPaid = double.tryParse(amountPaidController.text);
      widget.client.product = productController.text;
      widget.client.quantity = quantityController.text;
      widget.client.paymentDate = paymentDate;

      // Retour à la page précédente avec le client mis à jour
      context.go('/infosclients');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Client modifié avec succès !"),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E40AF)),
          onPressed: () => context.go('/infosclients'),
        ),
        title: Text(
          "Modifier ${widget.client.name}",
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF3B82F6)),
            onPressed: isSaving ? null : saveChanges,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),

      // ================= BODY =================
      body: Stack(
        children: [
          // ========== FOND BLEU CLAIR SUR LES CÔTÉS ==========
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE0F2FE), // Bleu clair uniforme
          ),

          // ========== PARTIE CENTRALE BLANCHE COURBÉE ==========
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // ========== EN-TÊTE ==========
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF60A5FA),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Modifier ${widget.client.name}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Mettez à jour les informations du client",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ========== FORMULAIRE ==========
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            // Champ Nom
                            _buildFormField(
                              label: "Nom complet",
                              controller: nameController,
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Nom du client requis";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Champ Téléphone
                            _buildFormField(
                              label: "Numéro de téléphone",
                              controller: phoneController,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Numéro de téléphone requis";
                                }
                                if (value.length < 9) {
                                  return "Numéro invalide";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Champ Adresse
                            _buildFormField(
                              label: "Adresse (optionnel)",
                              controller: addressController,
                              icon: Icons.location_on_outlined,
                            ),

                            const SizedBox(height: 20),

                            // Champ Produit
                            _buildFormField(
                              label: "Produit",
                              controller: productController,
                              icon: Icons.shopping_cart_outlined,
                            ),

                            const SizedBox(height: 20),

                            // Champ Quantité
                            _buildFormField(
                              label: "Quantité",
                              controller: quantityController,
                              icon: Icons.numbers_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                                  return "Quantité invalide";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Champ Montant dû
                            _buildFormField(
                              label: "Montant dû (FCFA)",
                              controller: amountDueController,
                              icon: Icons.money_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                                  return "Montant invalide";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Champ Montant payé
                            _buildFormField(
                              label: "Montant payé (FCFA) - optionnel",
                              controller: amountPaidController,
                              icon: Icons.payments_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                                  return "Montant invalide";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Champ Date de paiement
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Date de paiement (optionnel)",
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: pickDate,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Icon(
                                            Icons.date_range_outlined,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            paymentDate == null
                                                ? "Sélectionner une date"
                                                : "${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}",
                                            style: TextStyle(
                                              color: paymentDate == null
                                                  ? Colors.grey.shade500
                                                  : const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                        if (paymentDate != null)
                                          IconButton(
                                            icon: const Icon(Icons.clear,
                                                size: 18, color: Colors.grey),
                                            onPressed: () {
                                              setState(() => paymentDate = null);
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Bouton de sauvegarde
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isSaving ? null : saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  elevation: 2,
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 20),
                                    SizedBox(width: 12),
                                    Text(
                                      "Sauvegarder les modifications",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Bouton d'annulation
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: isSaving ? null : () => context.go('/infosclients'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF64748B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  "Annuler",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
        ],
      ),
    );
  }

  // ========== WIDGET DE CHAMP DE FORMULAIRE RÉUTILISABLE ==========
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: label.contains("optionnel")
                  ? label.replaceAll(" - optionnel", "")
                  : label,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.grey.shade500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}