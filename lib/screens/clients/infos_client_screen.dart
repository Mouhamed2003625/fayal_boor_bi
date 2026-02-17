import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/client_model.dart';
import '../../models/debt_model.dart';
import '../../providers/client_provider.dart';

class InfosClientScreen extends ConsumerWidget {
  final Client client;

  const InfosClientScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Debt> clientDebts = client.debts;

    final double totalDebt = clientDebts.fold(0.0, (sum, d) => sum + d.amount);
    final double totalPaid = clientDebts.fold(0.0, (sum, d) => sum + d.paidAmount);
    final double balance = totalDebt - totalPaid;
    final double percentage = totalDebt == 0 ? 0 : (totalPaid / totalDebt) * 100;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(client.name, style: const TextStyle(color: Color(0xFF1E293B))),
        iconTheme: const IconThemeData(color: Color(0xFF3B82F6)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.goNamed('editclient', extra: client),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF3B82F6),
          onPressed: () {
            context.goNamed("clientScreen"); // revient à la page précédente
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientInfo(),
            const SizedBox(height: 20),
            _buildStats(balance, percentage, clientDebts.length),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.goNamed('ajoutdebt', extra: client),
                    icon: const Icon(Icons.add),
                    label: const Text("Ajouter une dette"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(context, ref, client),
                    icon: const Icon(Icons.delete),
                    label: const Text("Supprimer"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: clientDebts.isEmpty
                  ? const Center(child: Text("Aucune dette"))
                  : ListView.builder(
                itemCount: clientDebts.length,
                itemBuilder: (context, index) => _debtCard(context, clientDebts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(client.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text("Téléphone : ${client.phone}", style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 4),
      Text("Adresse : ${client.address ?? "Non renseignée"}", style: const TextStyle(fontSize: 16)),
    ],
  );

  Widget _buildStats(double balance, double percentage, int debtCount) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Solde : ${balance.toStringAsFixed(0)} FCFA", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text("Progression : ${percentage.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text("Nombre de dettes : $debtCount", style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );

  Widget _debtCard(BuildContext context, Debt debt) {
    final double debtBalance = debt.amount - debt.paidAmount;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text("${debt.amount.toStringAsFixed(0)} FCFA"),
        subtitle: Text(
          "Solde : ${debtBalance.toStringAsFixed(0)} FCFA",
          style: TextStyle(
              color: debtBalance == 0 ? Colors.green : Colors.red.shade600, fontWeight: FontWeight.w500),
        ),
        trailing: Text(
          debt.isPaid ? "Payée" : "En attente",
          style: TextStyle(color: debt.isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
        ),
        onTap: () => context.goNamed('debt-details', extra: debt),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Client client) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Êtes-vous sûr de vouloir supprimer ce client ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () async {
              Navigator.pop(context); // Ferme le dialogue
              try {
                // Appel API / Provider pour supprimer le client
                await ref.read(clientProvider.notifier).deleteClient(client.id);

                // Afficher confirmation
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Client supprimé avec succès"),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                // Ici on reste sur la page InfosClientScreen
                // Si tu veux, tu peux actualiser le client ou son état
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erreur lors de la suppression : $e"),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text("Supprimer"),
          )
        ],
      ),
    );
  }
}
