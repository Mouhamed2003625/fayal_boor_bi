import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/client_model.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../providers/client_provider.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  final Client? client;

  const AddPaymentScreen({super.key, this.client});

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime? paymentDate;
  Client? selectedClient;

  @override
  void initState() {
    super.initState();
    selectedClient = widget.client;
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() => paymentDate = date);
    }
  }

  Future<void> savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner un client")),
      );
      return;
    }

    if (paymentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une date")),
      );
      return;
    }

    try {
      final payment = Payment(
        id: null, // ✅ auto généré par backend
        debtId: selectedClient!.id, // ✅ IMPORTANT
        amount: double.parse(amountController.text.trim()),
        paymentDate: paymentDate!,
        notes: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        userId: 1, // ⚠ mets ici l'id réel de l'utilisateur connecté
      );

      await ref.read(paymentProvider.notifier).addPayment(payment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paiement ajouté avec succès")),
      );

      context.pop(); // ✅ plus sûr que go('/payment')
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientState = ref.watch(clientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau Paiement"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: savePayment,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              /// ================= CLIENT =================
              const Text("Client"),
              const SizedBox(height: 8),

              clientState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Client>(
                value: selectedClient,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                hint: const Text("Sélectionner un client"),
                items: clientState.clients.map((client) {
                  return DropdownMenuItem<Client>(
                    value: client,
                    child: Text(client.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedClient = value);
                },
                validator: (value) =>
                value == null ? "Client requis" : null,
              ),

              const SizedBox(height: 20),

              /// ================= MONTANT =================
              TextFormField(
                controller: amountController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Montant",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Montant requis";
                  }
                  if (double.tryParse(value) == null) {
                    return "Montant invalide";
                  }
                  if (double.parse(value) <= 0) {
                    return "Montant doit être > 0";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              /// ================= DATE =================
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Date du paiement"),
                subtitle: Text(
                  paymentDate == null
                      ? "Sélectionner une date"
                      : "${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: pickDate,
              ),

              const SizedBox(height: 20),

              /// ================= NOTE =================
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Note (optionnel)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: savePayment,
                child: const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
