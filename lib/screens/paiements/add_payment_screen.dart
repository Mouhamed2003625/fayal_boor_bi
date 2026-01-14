import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/client_model.dart';

class AddPaymentScreen extends StatefulWidget {
  final Client? client;

  const AddPaymentScreen({super.key, this.client});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  late TextEditingController clientNameController;

  DateTime? paymentDate;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    clientNameController = TextEditingController(
      text: widget.client?.name ?? '',
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    clientNameController.dispose();
    super.dispose();
  }

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

  void savePayment() {
    if (!_formKey.currentState!.validate()) return;

    if (paymentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner une date"),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isSaving = false);

      print("====== NOUVEAU PAIEMENT ======");
      print("Client : ${clientNameController.text}");
      print("Montant : ${amountController.text}");
      print("Date : $paymentDate");
      print("Note : ${noteController.text}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Paiement ajouté avec succès"),
          backgroundColor: Color(0xFF16A34A),
        ),
      );

      // Retour à la page précédente après succès
      context.go('/payment');
    });
  }

  // Méthode pour retourner à la page précédente
  void _goBack() {
    context.go('/payment');
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
          onPressed: () => context.go('/payment'),// Utilise la même méthode
        ),
        title: const Text(
          "Nouveau Paiement",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF3B82F6)),
            onPressed: isSaving ? null : savePayment,
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
                            Icons.payment,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nouveau Paiement",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.client != null
                                    ? "Client : ${widget.client!.name}"
                                    : "Saisissez les informations",
                                style: const TextStyle(
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
                            // Champ Client
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Client",
                                  style: TextStyle(
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
                                    controller: clientNameController,
                                    enabled: widget.client == null,
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Nom du client",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: Colors.grey.shade500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (widget.client == null &&
                                          (value == null || value.trim().isEmpty)) {
                                        return "Nom du client requis";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Champ Montant
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Montant",
                                  style: TextStyle(
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
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Montant en FCFA",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.attach_money,
                                        color: Colors.grey.shade500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Montant requis";
                                      }
                                      if (double.tryParse(value) == null) {
                                        return "Montant invalide";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Champ Date
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Date du paiement",
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

                            const SizedBox(height: 20),

                            // Champ Note (optionnel)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Note (optionnel)",
                                  style: TextStyle(
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
                                    controller: noteController,
                                    maxLines: 3,
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Ajouter une note...",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
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
                                onPressed: isSaving ? null : savePayment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18),
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 20),
                                    SizedBox(width: 12),
                                    Text(
                                      "Enregistrer le paiement",
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

                            // Bouton d'annulation - MÊME DESTINATION QUE LE BOUTON RETOUR
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: isSaving ? null : _goBack, // Utilise la même méthode
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF64748B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18),
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
}