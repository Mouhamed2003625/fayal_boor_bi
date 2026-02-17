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

    // Initialiser les contrôleurs avec les valeurs existantes
    _productCtrl = TextEditingController(text: widget.debt.product);
    _quantityCtrl =
        TextEditingController(text: widget.debt.quantity.toString());
    _amountCtrl = TextEditingController(text: widget.debt.amount.toString());

    // S'assurer que dueDate n'est pas null
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
      // Créer l'objet Debt à envoyer au provider
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

      // Retour à la liste des dettes
      context.go('/debts');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la dette'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Produit
              TextFormField(
                controller: _productCtrl,
                decoration: const InputDecoration(
                  labelText: 'Produit',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Produit requis' : null,
              ),
              const SizedBox(height: 16),

              // Quantité
              TextFormField(
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final val = int.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Quantité invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Montant
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date d'échéance
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Date d'échéance"),
                subtitle: Text(
                  "${_selectedDueDate.day.toString().padLeft(2, '0')}/"
                      "${_selectedDueDate.month.toString().padLeft(2, '0')}/"
                      "${_selectedDueDate.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),

              // Bouton Enregistrer
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submit,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
