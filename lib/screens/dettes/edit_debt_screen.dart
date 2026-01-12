import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/debt_model.dart';
import '../../repositories/debt_repository.dart';
import '../../services/debt_repository_mysql.dart';
//import '../services/debt_repository_mysql.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/debt_repository_mysql.dart' as repo;

class EditDebtScreen extends ConsumerStatefulWidget {
  final Debt debt;

  const EditDebtScreen({super.key, required this.debt});

  @override
  ConsumerState<EditDebtScreen> createState() => _EditDebtScreenState();
}

class _EditDebtScreenState extends ConsumerState<EditDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  late DateTime _selectedDate;
  late bool _isPaid;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clientCtrl = TextEditingController(text: widget.debt.clientName);
    _phoneCtrl = TextEditingController(text: widget.debt.phoneNumber);
    _amountCtrl =
        TextEditingController(text: widget.debt.amount.toStringAsFixed(2));
    _descCtrl = TextEditingController(text: widget.debt.description);
    _selectedDate = widget.debt.dates;
    _isPaid = widget.debt.isPaid;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
     // final repo = ref.read(debtRepositoryMySqlProvider);

      // Utilisation de updateDebt au lieu de addDebt
      await repo.updateDebt(
        clientName: _clientCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        amount: double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
        description: _descCtrl.text.trim(),
        dates: _selectedDate,
        isPaid: _isPaid,
        userId: widget.debt.userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dette modifiée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigue vers la liste des dettes
      context.go('/debts');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _clientCtrl.dispose();
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier la dette')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nom du client
              TextFormField(
                controller: _clientCtrl,
                decoration: const InputDecoration(labelText: 'Nom du client'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Téléphone
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Montant
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Montant'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final value = double.tryParse(v ?? '');
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  if (value == null || value <= 0) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 12),
                  Text(
                    'Date : ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Modifier'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Statut payé
              Row(
                children: [
                  const Text('Dette payée ?'),
                  Switch(
                    value: _isPaid,
                    onChanged: (v) => setState(() => _isPaid = v),
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
