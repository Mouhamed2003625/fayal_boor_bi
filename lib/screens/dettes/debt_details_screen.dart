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
            Text('Client : ${debt.clientName}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Téléphone : ${debt.phoneNumber}'),
            const SizedBox(height: 8),
            Text('Montant : ${debt.amount} FCFA'),
            const SizedBox(height: 8),
            Text('Date : ${debt.dates.day}/${debt.dates.month}/${debt.dates.year}'),
            const SizedBox(height: 8),
            Text('Statut : ${debt.isPaid ? "Payée" : "Non payée"}'),
            const SizedBox(height: 16),
            Text('Description :'),
            Text(debt.description),
          ],
        ),
      ),
    );
  }
}
