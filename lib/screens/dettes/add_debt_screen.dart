import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/debt_repository_mysql.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  const AddDebtScreen({super.key});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isPaid = false;
  bool _isLoading = false;

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
      final repo = ref.read(debtRepositoryMySqlProvider);

      // Conversion sûre du montant
      final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
      if (amount <= 0) throw 'Montant invalide';

      // Appel backend
      await repo.addDebt(
        clientName: _clientCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        amount: amount,
        description: _descCtrl.text.trim(),
        dates: _selectedDate,
        isPaid: _isPaid,
        userId: 'mobile-user',
      );

      if (!mounted) return;

      // SnackBar pour succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dette ajoutée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigator.pop sécurisé après le frame courant
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/debts'); // ou la page que tu veux
      },
    );
    } catch (e) {
      if (!mounted) return;

      // SnackBar pour erreur
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
      appBar: AppBar(title: const Text('Ajouter une Dette')),
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

              // Bouton Ajouter
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submit,
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
