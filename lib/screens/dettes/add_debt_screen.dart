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
  static const Color primaryBlue = Color(0xFF003366);

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

  /// Fonction pour gérer le retour à la page précédente
  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      // Si on ne peut pas revenir en arrière, rediriger vers la page des dettes
      context.go('/debts');
    }
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
        dueDate: _selectedDueDate,
      );

      if (!mounted) return;

      // Message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Dette ajoutée avec succès'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      context.go('/debts');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur : $e'),
          backgroundColor: Colors.red,
        ),
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
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _goBack,
          tooltip: 'Retour',
        ),
        title: const Text(
          'Ajouter une dette',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Bouton d'aide optionnel
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Remplissez tous les champs pour ajouter une dette"),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 3),
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
          padding: const EdgeInsets.all(20),
          child: clientState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
            key: _formKey,
            child: ListView(
              children: [
                // Sélection du client
                DropdownButtonFormField<Client>(
                  value: _selectedClient,
                  decoration: InputDecoration(
                    labelText: 'Client',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
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

                // Produit
                TextFormField(
                  controller: _productCtrl,
                  decoration: InputDecoration(
                    labelText: 'Produit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Produit requis' : null,
                ),
                const SizedBox(height: 16),

                // Quantité
                TextFormField(
                  controller: _quantityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Montant',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
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
                  trailing: Icon(Icons.calendar_today, color: primaryBlue),
                  onTap: _pickDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton d'enregistrement
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
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