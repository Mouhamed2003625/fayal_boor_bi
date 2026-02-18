import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/debt_model.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../providers/debt_provider.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  final int debtId;

  const AddPaymentScreen({super.key, required this.debtId});

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  static const Color primaryBlue = Color(0xFF003366);

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _methodController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _methodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Fonction pour gérer le retour à la page précédente
  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('details', pathParameters: {'id': widget.debtId.toString()});
    }
  }

  Debt? get _debt {
    final debtState = ref.watch(debtProvider);
    try {
      return debtState.debts.firstWhere((d) => d.id == widget.debtId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitPayment() async {
    final debt = _debt;
    if (debt == null) return;

    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());

    final payment = Payment(
      debtId: debt.id,
      amount: amount,
      paymentDate: DateTime.now(),
      method: _methodController.text.trim().isEmpty
          ? null
          : _methodController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      reference: null,
      userId: 1,
    );

    setState(() => _isSubmitting = true);

    try {
      await ref.read(paymentProvider.notifier).addPayment(payment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Paiement ajouté avec succès"),
          backgroundColor: Colors.green,
        ),
      );

      context.goNamed('payments');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final debt = _debt;

    if (debt == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
            tooltip: 'Retour',
          ),
          title: const Text(
            "Ajouter un paiement",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(child: Text("Dette introuvable")),
      );
    }

    final remainingAmount = debt.amount - debt.paidAmount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _goBack,
          tooltip: 'Retour',
        ),
        title: const Text(
          "Ajouter un paiement",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Saisissez le montant du paiement"),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            tooltip: 'Aide',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, primaryBlue.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dette: ${debt.product}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                "Solde restant: ${remainingAmount.toStringAsFixed(0)} FCFA",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Montant du paiement",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
                    prefixIcon: Icon(Icons.attach_money, color: primaryBlue),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Montant requis";
                    }
                    final num? parsed = num.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) {
                      return "Montant invalide";
                    }
                    if (parsed > remainingAmount) {
                      return "Le paiement dépasse le solde restant";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _methodController,
                  decoration: InputDecoration(
                    labelText: "Méthode de paiement",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
                    prefixIcon: Icon(Icons.payment, color: primaryBlue),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: "Notes",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
                    prefixIcon: Icon(Icons.note, color: primaryBlue),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Ajouter le paiement",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}