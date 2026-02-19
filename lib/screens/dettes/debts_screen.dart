import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/debt_provider.dart';
import '../../models/debt_model.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  /// Fonction pour gérer le retour à la page précédente
  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('dashboard');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtState = ref.watch(debtProvider);
    final debts = debtState.debts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _goBack(context),
          tooltip: 'Retour',
        ),
        title: const Text(
          'Liste des dettes',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.read(debtProvider.notifier).loadDebts(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF003366),
        onPressed: () => context.goNamed('ajoutdebt'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFF003366).withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: debtState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : debtState.error != null
            ? Center(child: Text('Erreur : ${debtState.error}'))
            : debts.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 20),
              const Text('Aucune dette enregistrée',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => context.goNamed('ajoutdebt'),
                icon: const Icon(Icons.add),
                label: const Text("Ajouter une dette"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        )
            : RefreshIndicator(
          onRefresh: () async =>
              ref.read(debtProvider.notifier).loadDebts(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final d = debts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                    child: const Icon(Icons.receipt, color: Color(0xFF003366)),
                  ),
                  title: Text(
                    d.product,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                      'Montant: ${d.amount.toStringAsFixed(0)} FCFA | Payé: ${d.paidAmount.toStringAsFixed(0)} FCFA'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: d.isPaid
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      d.isPaid ? "Payée" : "En attente",
                      style: TextStyle(
                        color: d.isPaid ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    context.goNamed(
                      'details',
                      pathParameters: {
                        'id': d.id.toString(),
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}