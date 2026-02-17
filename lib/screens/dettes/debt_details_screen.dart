import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/debt_model.dart';

class DebtDetailsScreen extends StatelessWidget {
  final Debt debt;

  const DebtDetailsScreen({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la dette'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('debts'), // Retour à l'écran précédent
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier cette dette',
            onPressed: () {
              // Navigation vers la page de modification
              context.goNamed(
                'editdebt',
                extra: debt, // On passe l'objet Debt pour l'édition
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client ID : ${debt.clientId}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Produit : ${debt.product}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Quantité : ${debt.quantity}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Montant : ${debt.amount.toStringAsFixed(2)} FCFA', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Montant payé : ${debt.paidAmount.toStringAsFixed(2)} FCFA', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Statut : ${debt.isPaid ? "Payée" : "Non payée"}',
                style: TextStyle(
                    fontSize: 18,
                    color: debt.isPaid ? Colors.green : Colors.red
                )),
            const SizedBox(height: 16),

            // Liste des paiements
            if (debt.payments.isNotEmpty) ...[
              const Text('Paiements :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: debt.payments.length,
                  itemBuilder: (context, index) {
                    final payment = debt.payments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text('${payment.amount.toStringAsFixed(2)} FCFA'),
                        subtitle: Text('Référence : ${payment.reference ?? "N/A"}'),
                        trailing: Text(payment.method ?? ''),
                      ),
                    );
                  },
                ),
              ),
            ] else
              const Text('Aucun paiement enregistré pour cette dette.'),
          ],
        ),
      ),
    );
  }
}
