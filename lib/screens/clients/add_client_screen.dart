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
        const SnackBar(
          content: Text("Client enregistré avec succès"),
          backgroundColor: Color(0xFF16A34A),
        ),
      );

      context.go('/clientScreen');
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
          onPressed: () => context.go('/clientScreen'),
        ),
        title: const Text(
          "Nouveau Client",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF3B82F6)),
            onPressed: isSaving ? null : saveClient,
            tooltip: 'Enregistrer',
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
                            Icons.person_add_alt_1,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nouveau Client",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Ajoutez les informations du client",
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
                              label: "Nom complet du client",
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
                              label: "Adresse du client (optionnel)",
                              controller: addressController,
                              icon: Icons.location_on_outlined,
                            ),

                            const SizedBox(height: 20),

                            // Champ Produit
                            _buildFormField(
                              label: "Nom du produit",
                              controller: productController,
                              icon: Icons.shopping_cart_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Nom du produit requis";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Champ Quantité
                            _buildFormField(
                              label: "Quantité",
                              controller: quantityController,
                              icon: Icons.numbers_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Quantité requise";
                                }
                                if (int.tryParse(value) == null) {
                                  return "Quantité invalide";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Champ Montant à payer
                            _buildFormField(
                              label: "Montant à payer (FCFA)",
                              controller: amountDueController,
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Montant requis";
                                }
                                if (double.tryParse(value) == null) {
                                  return "Montant invalide";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Champ Montant versé
                            _buildFormField(
                              label: "Montant versé (FCFA) - optionnel",
                              controller: amountPaidController,
                              icon: Icons.payments_outlined,
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 20),

                            // Champ Date de versement
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Date de versement",
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

                            // Bouton d'enregistrement
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isSaving ? null : saveClient,
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
                                      "Enregistrer le client",
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
                                onPressed: isSaving ? null : () => context.go('/clientScreen'),
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