import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/debt_provider.dart';
import '../../models/debt_model.dart';

class DebtDetailsScreen extends ConsumerWidget {
  final int debtId;

  const DebtDetailsScreen({
    super.key,
    required this.debtId,
  });

  /// Fonction pour gérer le retour à la page précédente
  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('debts');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtState = ref.watch(debtProvider);

    if (debtState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final debt = debtState.debts.firstWhere(
          (d) => d.id == debtId,
      orElse: () => throw Exception("Dette non trouvée"),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _goBack(context),
          tooltip: 'Retour',
        ),
        title: const Text(
          'Détails de la dette',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Modifier cette dette',
            onPressed: () {
              context.goNamed(
                'editdebt',
                extra: debt,
              );
            },
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      _buildDetailRow('Client', 'Client #${debt.clientId}'),
                      const Divider(),
                      _buildDetailRow('Produit', debt.product),
                      const Divider(),
                      _buildDetailRow('Quantité', '${debt.quantity}'),
                      const Divider(),
                      _buildDetailRow('Montant total', '${debt.amount.toStringAsFixed(0)} FCFA'),
                      const Divider(),
                      _buildDetailRow('Montant payé', '${debt.paidAmount.toStringAsFixed(0)} FCFA'),
                      const Divider(),
                      Row(
                        children: [
                          const Text('Statut : ', style: TextStyle(fontSize: 18)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: debt.isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              debt.isPaid ? "Payée" : "Non payée",
                              style: TextStyle(
                                fontSize: 18,
                                color: debt.isPaid ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (debt.payments.isNotEmpty) ...[
                const Text(
                  'Historique des paiements :',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: debt.payments.length,
                    itemBuilder: (context, index) {
                      final payment = debt.payments[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF003366).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.payment, color: Color(0xFF003366)),
                          ),
                          title: Text(
                            '${payment.amount.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Référence : ${payment.reference ?? "N/A"}',
                          ),
                          trailing: Text(payment.method ?? ''),
                        ),
                      );
                    },
                  ),
                ),
              ] else
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.payment, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun paiement enregistré pour cette dette.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),

      floatingActionButton: debt.isPaid
          ? null
          : FloatingActionButton.extended(
        backgroundColor: const Color(0xFF003366),
        icon: const Icon(Icons.payment),
        label: const Text('Payer la dette'),
        onPressed: () {
          context.goNamed(
            'addPayment',
            pathParameters: {'id': debt.id.toString()},
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label : ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}