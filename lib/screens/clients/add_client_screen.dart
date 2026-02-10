import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String? errorMessage;

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

  Future<void> saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      // Préparer les données pour l'API
      final Map<String, dynamic> clientData = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'product': productController.text.trim(),
        'quantity': quantityController.text.trim(),
        'amountDue': amountDueController.text.isNotEmpty
            ? double.parse(amountDueController.text)
            : null,
        'amountPaid': amountPaidController.text.isNotEmpty
            ? double.parse(amountPaidController.text)
            : null,
        'paymentDate': paymentDate?.toIso8601String(),
      };

      // Supprimer les champs null
      clientData.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

      // Appeler l'API
      final response = await http.post(
        Uri.parse('http://localhost/fayal_boor_bi/clients/client_create.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(clientData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['ok'] == true) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Client enregistré avec succès'),
            backgroundColor: const Color(0xFF16A34A),
            duration: const Duration(seconds: 2),
          ),
        );

        // Attendre un peu avant la navigation pour voir le message
        await Future.delayed(const Duration(milliseconds: 500));

        // Retourner à l'écran des clients
        if (context.mounted) {
          context.go('/clientScreen');
        }
      } else {
        // Erreur de l'API
        setState(() {
          errorMessage = responseData['message'] ?? 'Erreur inconnue';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Erreur lors de l\'enregistrement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FormatException catch (e) {
      setState(() {
        errorMessage = 'Erreur de format: ${e.message}';
      });
    } on http.ClientException catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion: ${e.message}';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur inattendue: $e';
      });
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
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
            color: const Color(0xFFE0F2FE),
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
                            // Afficher les erreurs
                            if (errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage!,
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

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
                                  return "Numéro invalide (minimum 9 chiffres)";
                                }
                                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return "Numéro invalide (chiffres seulement)";
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
                                  return "Quantité invalide (nombre entier)";
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
                                if (double.parse(value) <= 0) {
                                  return "Montant doit être supérieur à 0";
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
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (double.tryParse(value) == null) {
                                    return "Montant invalide";
                                  }
                                  if (double.parse(value) < 0) {
                                    return "Montant ne peut pas être négatif";
                                  }
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Champ Date de versement
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Date de versement (optionnel)",
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