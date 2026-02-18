import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/debt_model.dart';
import '../../providers/debt_provider.dart';

class EditDebtScreen extends ConsumerStatefulWidget {
  final Debt debt;

  const EditDebtScreen({super.key, required this.debt});

  @override
  ConsumerState<EditDebtScreen> createState() => _EditDebtScreenState();
}

class _EditDebtScreenState extends ConsumerState<EditDebtScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _productCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _amountCtrl;

  late DateTime _selectedDueDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _productCtrl = TextEditingController(text: widget.debt.product);
    _quantityCtrl =
        TextEditingController(text: widget.debt.quantity.toString());
    _amountCtrl = TextEditingController(text: widget.debt.amount.toString());

    _selectedDueDate = widget.debt.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _productCtrl.dispose();
    _quantityCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedDebt = Debt(
        id: widget.debt.id,
        clientId: widget.debt.clientId,
        product: _productCtrl.text.trim(),
        quantity: int.parse(_quantityCtrl.text.trim()),
        amount: double.parse(_amountCtrl.text.trim()),
        dueDate: _selectedDueDate,
        payments: widget.debt.payments,
        client: widget.debt.client,
      );

      await ref.read(debtProvider.notifier).updateDebt(updatedDebt);

      if (!mounted) return;

      context.go('/debts');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Fonction pour gérer le retour à la page précédente
  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/debts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _goBack,
          tooltip: 'Retour',
        ),
        title: const Text(
          'Modifier la dette',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _isLoading ? null : _submit,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFF003366).withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _productCtrl,
                  decoration: InputDecoration(
                    labelText: 'Produit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF003366), width: 2),
                    ),
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Produit requis' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _quantityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF003366), width: 2),
                    ),
                  ),
                  validator: (v) {
                    final val = int.tryParse(v ?? '');
                    if (val == null || val <= 0) return 'Quantité invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Montant',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF003366), width: 2),
                    ),
                  ),
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null || val <= 0) return 'Montant invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Date d'échéance"),
                  subtitle: Text(
                    "${_selectedDueDate.day.toString().padLeft(2, '0')}/"
                        "${_selectedDueDate.month.toString().padLeft(2, '0')}/"
                        "${_selectedDueDate.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Color(0xFF003366)),
                  onTap: _pickDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer',
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