import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/debt_provider.dart';
import '../../models/debt_model.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtState = ref.watch(debtProvider);
    final debts = debtState.debts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des dettes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF3B82F6),
          onPressed: () {
            context.goNamed("dashboard");
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('ajoutdebt'),
        child: const Icon(Icons.add),
      ),
      body: debtState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : debtState.error != null
          ? Center(child: Text('Erreur : ${debtState.error}'))
          : debts.isEmpty
          ? const Center(child: Text('Aucune dette enregistrée'))
          : ListView.builder(
        itemCount: debts.length,
        itemBuilder: (context, index) {
          final d = debts[index];
          return Card(
            child: ListTile(
              title: Text(d.product),
              subtitle: Text(
                  'Montant: ${d.amount.toStringAsFixed(0)} FCFA | Payé: ${d.paidAmount.toStringAsFixed(0)} FCFA'),
              trailing: Icon(
                d.isPaid ? Icons.check_circle : Icons.warning,
                color: d.isPaid ? Colors.green : Colors.red,
              ),
              onTap: () {
                // Navigation vers la page de détails
                context.goNamed(
                  'details',
                  extra: d, // on passe l'objet Debt
                );
              },
            ),
          );
        },
      ),
    );
  }
}
