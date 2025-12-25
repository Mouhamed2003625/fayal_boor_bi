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
    );

    if (date != null) {
      setState(() => paymentDate = date);
    }
  }

  void savePayment() {
    if (!_formKey.currentState!.validate()) return;

    if (paymentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une date")),
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
        const SnackBar(content: Text("Paiement ajouté avec succès")),
      );

      context.pop(); // ✅ cohérent avec go_router
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
            context.go('/payment');
          },
        ),
        title: const Text(
          "Ajouter un paiement",
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
                      child: const Icon(Icons.payment,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.client != null
                            ? "Paiement pour ${widget.client!.name}"
                            : "Paiement nouveau client",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------- FORM CARD --------
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: clientNameController,
                          enabled: widget.client == null,
                          decoration: const InputDecoration(
                            labelText: "Nom du client",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (widget.client == null &&
                                (v == null || v.trim().isEmpty)) {
                              return "Nom du client requis";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Montant versé (FCFA)",
                            prefixIcon: Icon(Icons.attach_money),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          v == null || v.isEmpty ? "Entrez un montant" : null,
                        ),
                        const SizedBox(height: 20),

                        InkWell(
                          onTap: pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Date du paiement",
                              prefixIcon: Icon(Icons.date_range),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              paymentDate == null
                                  ? "Sélectionner une date"
                                  : "${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}",
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: noteController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: "Note (optionnel)",
                            prefixIcon: Icon(Icons.note_alt),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 30),

                        ElevatedButton(
                          onPressed: isSaving ? null : savePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B2FF7),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: isSaving
                              ? const CircularProgressIndicator(
                              color: Colors.black87)
                              : const Text(
                          "Enregisrer le paiement",
                          style: TextStyle(fontSize: 18, color: Colors.black),
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
