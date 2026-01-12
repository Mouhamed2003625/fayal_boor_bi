import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/debt_provider.dart';
import '../../models/debt_model.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des dettes'),
      ),

      // ➕ AJOUT
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/ajoutdebt'); // ✅ CORRIGÉ
        },
        child: const Icon(Icons.add),
      ),

      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (debts) {
          if (debts.isEmpty) {
            return const Center(child: Text('Aucune dette enregistrée'));
          }

          return ListView.builder(
            itemCount: debts.length,
            itemBuilder: (context, i) {
              final d = debts[i];

              return Card(
                child: ListTile(
                  title: Text(d.clientName),
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
          );
        },
      ),
    );
  }
}
