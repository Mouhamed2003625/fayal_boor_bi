import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/debt_model.dart';
import '../../providers/debt_provider.dart';
import '../../repositories/debt_repository_mysql.dart';

class EditDebtScreen extends ConsumerStatefulWidget {
  final Debt debt;

  const EditDebtScreen({super.key, required this.debt});

  @override
  ConsumerState<EditDebtScreen> createState() => _EditDebtScreenState();
}

class _EditDebtScreenState extends ConsumerState<EditDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientIdCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _paymentMethodCtrl;
  late TextEditingController _paymentReferenceCtrl;
  late TextEditingController _notesCtrl;

  late DateTime _dueDate;
  late DateTime? _paymentDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialisation des contrôleurs avec les valeurs de la dette existante
    _clientIdCtrl = TextEditingController(text: widget.debt.clientId);
    _amountCtrl = TextEditingController(text: widget.debt.amount.toStringAsFixed(2));
    _descCtrl = TextEditingController(text: widget.debt.description);
    _paymentMethodCtrl = TextEditingController(text: widget.debt.paymentMethod ?? '');
    _paymentReferenceCtrl = TextEditingController(text: widget.debt.paymentReference ?? '');
    _notesCtrl = TextEditingController(text: widget.debt.notes ?? '');

    // Initialisation des dates
    _dueDate = widget.debt.dueDate;
    _paymentDate = widget.debt.isPaid ? widget.debt.dates : null;
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _pickPaymentDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _paymentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _paymentDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(debtRepositoryProvider);

      final amount = double.tryParse(_amountCtrl.text.trim());
      if (amount == null || amount <= 0) {
        throw Exception('Montant invalide');
      }

      // 🔥 Reconstruction DU modèle Debt (source de vérité)
      final updatedDebt = Debt(
        id: widget.debt.id,
        clientId: _clientIdCtrl.text.trim(),
        client: widget.debt.client, // on conserve
        amount: amount,
        description: _descCtrl.text.trim(),
        createdAt: widget.debt.createdAt, // jamais modifiée
        dueDate: _dueDate,
        dates: _paymentDate, // null = non payée
        paymentMethod: _paymentMethodCtrl.text.trim().isNotEmpty
            ? _paymentMethodCtrl.text.trim()
            : null,
        paymentReference: _paymentReferenceCtrl.text.trim().isNotEmpty
            ? _paymentReferenceCtrl.text.trim()
            : null,
        notes: _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
        userId: widget.debt.userId,
      );

      await repo.updateDebt(updatedDebt);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dette modifiée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

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
    _clientIdCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _paymentMethodCtrl.dispose();
    _paymentReferenceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la dette'),
        actions: [
          // Option pour supprimer la dette
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Affichage informatif
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modification de la dette #${widget.debt.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Créée le: ${widget.debt.createdAt.day}/${widget.debt.createdAt.month}/${widget.debt.createdAt.year}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (widget.debt.isPaid && widget.debt.dates != null)
                        Text(
                          'Payée le: ${widget.debt.dates!.day}/${widget.debt.dates!.month}/${widget.debt.dates!.year}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      if (widget.debt.isOverdue)
                        Text(
                          '⚠️ En retard de ${widget.debt.daysOverdue} jours',
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ID du client (obligatoire)
              TextFormField(
                controller: _clientIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'ID du client*',
                  hintText: 'Ex: CLIENT123',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'ID client requis' : null,
              ),
              const SizedBox(height: 16),

              // Montant (obligatoire)
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Montant*',
                  hintText: 'Ex: 1500.50',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final value = double.tryParse(v ?? '');
                  if (v == null || v.trim().isEmpty) return 'Montant requis';
                  if (value == null || value <= 0) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description (obligatoire)
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  hintText: 'Détails de la dette/achat',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Description requise' : null,
              ),
              const SizedBox(height: 16),

              // Date d'échéance
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date d\'échéance*',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: _dueDate.isBefore(DateTime.now())
                                ? Colors.red
                                : Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _dueDate.isBefore(DateTime.now())
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _pickDueDate,
                            child: const Text('Changer'),
                          ),
                        ],
                      ),
                      if (_dueDate.isBefore(DateTime.now()))
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '⚠️ Cette date est passée',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Section de paiement
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statut de paiement',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Date de paiement
                      Row(
                        children: [
                          Icon(
                            _paymentDate != null
                                ? Icons.check_circle
                                : Icons.pending_actions,
                            color: _paymentDate != null
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          const Text('Statut :'),
                          const SizedBox(width: 8),
                          Text(
                            _paymentDate != null ? 'Payée' : 'Non payée',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _paymentDate != null
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          const Spacer(),
                          if (_paymentDate != null)
                            TextButton(
                              onPressed: () => setState(() => _paymentDate = null),
                              child: const Text('Marquer non payée'),
                            ),
                        ],
                      ),

                      if (_paymentDate != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Date de paiement :'),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_paymentDate!.day}/${_paymentDate!.month}/${_paymentDate!.year}',
                              ),
                            ),
                            TextButton(
                              onPressed: _pickPaymentDate,
                              child: const Text('Modifier'),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _pickPaymentDate,
                          icon: const Icon(Icons.payment),
                          label: const Text('Marquer comme payée'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Méthode de paiement
                      TextFormField(
                        controller: _paymentMethodCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Méthode de paiement',
                          hintText: 'Ex: Mobile Money, Espèces, Virement',
                          prefixIcon: Icon(Icons.payment),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Référence de paiement
                      TextFormField(
                        controller: _paymentReferenceCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Référence de transaction',
                          hintText: 'Ex: TRX123456',
                          prefixIcon: Icon(Icons.receipt),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes supplémentaires
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes supplémentaires',
                  hintText: 'Informations complémentaires',
                  prefixIcon: Icon(Icons.note_add),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Boutons d'action
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/debts'),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la dette'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette dette ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final repo = ref.read(debtRepositoryProvider);
        await repo.deleteDebt(widget.debt.id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dette supprimée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

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
  }
}