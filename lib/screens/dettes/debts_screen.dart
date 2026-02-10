import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/debt_provider.dart';


class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⚡ Watch le notifier pour obtenir l'état
    final debtState = ref.watch(debtProvider);

    // ⚡ Load debts si vide
    if (!debtState.isLoading && debtState.debts.isEmpty && debtState.error == null) {
      // On peut appeler loadDebts ici
      Future.microtask(() => ref.read(debtProvider.notifier).loadDebts());
    }

    final debts = debtState.debts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des dettes'),
      ),

      // ➕ AJOUT
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/ajoutdebt');
        },
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
        itemBuilder: (context, i) {
          final d = debts[i];

          return Card(
            child: ListTile(
              title: Text(d.client?.name ?? 'Client inconnu'),
              subtitle: Text('${d.amount} FCFA'),
              trailing: Icon(
                d.isPaid ? Icons.check_circle : Icons.warning,
                color: d.isPaid ? Colors.green : Colors.red,
              ),
              onTap: () {
                context.go(
                  '/editdebt',
                  extra: d,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
