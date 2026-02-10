import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../providers/debt_provider.dart';
import '../../models/client_model.dart';
import '../../services/api_config.dart';

/// ⚠️ À adapter selon Flutter Web / Mobile

// -----------------------------------------------------------------------------
// Provider clients (JSON = LIST DIRECTE)
// -----------------------------------------------------------------------------
final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final response = await http.get(
    Uri.parse(ApiConfig.listClientUrl()),
    headers: {'Accept': 'application/json'},
  );

  if (response.statusCode != 200) {
    throw Exception('Erreur HTTP ${response.statusCode}');
  }

  final List data = json.decode(response.body);
  return data.map((e) => Client.fromJson(e)).toList();
});

class AddDebtScreen extends ConsumerStatefulWidget {
  const AddDebtScreen({super.key});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _paymentMethodCtrl = TextEditingController();
  final _paymentReferenceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Client? _selectedClient;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _paymentDate;

  bool _isLoading = false;
  bool _showClientList = false;

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _pickPaymentDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _paymentDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un client')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(debtRepositoryProvider);

      final amount = double.parse(_amountCtrl.text.trim());

      await repo.addDebt(
        clientId: _selectedClient!.id,
        amount: amount,
        description: _descCtrl.text.trim(),
        dueDate: _dueDate,
        //dates : _paymentDate,
        paymentMethod: _paymentMethodCtrl.text.trim().isNotEmpty
            ? _paymentMethodCtrl.text.trim()
            : null,
        paymentReference: _paymentReferenceCtrl.text.trim().isNotEmpty
            ? _paymentReferenceCtrl.text.trim()
            : null,
        notes: _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
        userId: 'mobile-user',
      );

      if (!mounted) return;
      context.go('/debts');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _paymentMethodCtrl.dispose();
    _paymentReferenceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une dette')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Client ---
              clientsAsync.when(
                data: (clients) => DropdownButtonFormField<Client>(
                  value: _selectedClient,
                  items: clients
                      .map(
                        (c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.name} (${c.phone})'),
                    ),
                  )
                      .toList(),
                  onChanged: (c) => setState(() => _selectedClient = c),
                  decoration: const InputDecoration(
                    labelText: 'Client*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null ? 'Client requis' : null,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Erreur: $e'),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Montant*',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || double.tryParse(v) == null)
                    ? 'Montant invalide'
                    : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Description requise' : null,
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
