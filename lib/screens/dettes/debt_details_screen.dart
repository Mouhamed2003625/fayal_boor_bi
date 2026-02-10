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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('details');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CORRECTION: Utiliser client?.name au lieu de client
            Text(
                'Client : ${debt.client?.name ?? "Client ${debt.clientId}"}',
                style: const TextStyle(fontSize: 18)
            ),
            const SizedBox(height: 8),
            // CORRECTION: Utiliser client?.phone au lieu de client
            Text('Téléphone : ${debt.client?.phone ?? "Non disponible"}'),
            const SizedBox(height: 8),
            // CORRECTION: Ajouter FCFA
            Text('Montant : ${debt.amount.toStringAsFixed(2)} FCFA'),
            const SizedBox(height: 8),
            // CORRECTION: Gérer le cas où dates est null
            Text(
              'Date : ${debt.dates != null ? '${debt.dates!.day}/${debt.dates!.month}/${debt.dates!.year}' : 'Non payée'}',
            ),
            const SizedBox(height: 8),
            Text('Statut : ${debt.isPaid ? "Payée" : "Non payée"}'),
            const SizedBox(height: 16),
            const Text('Description :'),
            Text(debt.description),
            // CORRECTION: Ajouter d'autres informations utiles
            const SizedBox(height: 16),
            if (debt.dueDate != null) ...[
              Text(
                'Date d\'échéance : ${debt.dueDate.day}/${debt.dueDate.month}/${debt.dueDate.year}',
              ),
              const SizedBox(height: 8),
            ],
            if (debt.createdAt != null) ...[
              Text(
                'Créée le : ${debt.createdAt.day}/${debt.createdAt.month}/${debt.createdAt.year}',
              ),
              const SizedBox(height: 8),
            ],
            if (debt.paymentMethod != null) ...[
              Text('Méthode de paiement : ${debt.paymentMethod}'),
              const SizedBox(height: 8),
            ],
            if (debt.paymentReference != null) ...[
              Text('Référence paiement : ${debt.paymentReference}'),
              const SizedBox(height: 8),
            ],
            if (debt.notes != null && debt.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Notes :'),
              Text(debt.notes!),
            ],
          ],
        ),
      ),
    );
  }
}