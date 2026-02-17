import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/client_model.dart';
import '../../providers/client_provider.dart';
import '../../providers/debt_provider.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  const AddDebtScreen({super.key});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();

  final _productCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  DateTime _selectedDueDate = DateTime.now();

  Client? _selectedClient;
  bool _isSubmitting = false;

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
    if (!_formKey.currentState!.validate() || _selectedClient == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(debtProvider.notifier).addDebt(
        clientId: _selectedClient!.id,
        product: _productCtrl.text.trim(),
        quantity: int.parse(_quantityCtrl.text.trim()),
        amount: double.parse(_amountCtrl.text.trim()),
        dueDate: _selectedDueDate, // DateTime ici
      );

      if (!mounted) return;
      context.go('/debts');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final clientState = ref.watch(clientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une dette'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF3B82F6),
          onPressed: () {
            if (_selectedClient != null) {
              context.goNamed("infosclients", extra: _selectedClient);
            } else {
              context.go('/clientScreen');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: clientState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Client>(
                value: _selectedClient,
                decoration: const InputDecoration(
                  labelText: 'Client',
                  border: OutlineInputBorder(),
                ),
                items: clientState.clients
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.name),
                ))
                    .toList(),
                onChanged: (c) => setState(() => _selectedClient = c),
                validator: (v) =>
                v == null ? 'Veuillez sélectionner un client' : null,
              ),
              const SizedBox(height: 16),
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
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              _isSubmitting
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
