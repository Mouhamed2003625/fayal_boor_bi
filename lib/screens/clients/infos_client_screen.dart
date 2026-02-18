import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/client_model.dart';
import '../../models/debt_model.dart';
import '../../providers/client_provider.dart';
import '../../providers/debt_provider.dart';

class InfosClientScreen extends ConsumerWidget {
  final Client client;

  const InfosClientScreen({super.key, required this.client});

  /// Fonction pour gérer le retour à la page précédente
  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed("clientScreen");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔹 État des clients
    final clientState = ref.watch(clientProvider);
    // 🔹 État des dettes
    final debtState = ref.watch(debtProvider);

    // 🔥 Si chargement
    if (clientState.isLoading || debtState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🔥 Si erreur
    if (clientState.error != null) {
      return Scaffold(body: Center(child: Text("Erreur client : ${clientState.error}")));
    }
    if (debtState.error != null) {
      return Scaffold(body: Center(child: Text("Erreur dettes : ${debtState.error}")));
    }

    // 🔹 Client mis à jour
    final updateClient = clientState.clients.firstWhere(
          (c) => c.id == client.id,
      orElse: () => client,
    );

    // 🔹 Filtrer les dettes du client
    final clientDebts = debtState.debts.where((d) => d.clientId == client.id).toList();

    // 🔹 Calculs
    final totalDebt = clientDebts.fold<double>(0, (sum, d) => sum + d.amount);
    final totalPaid = clientDebts.fold<double>(0, (sum, d) => sum + d.paidAmount);
    final balance = totalDebt - totalPaid;
    final percentage = totalDebt == 0 ? 0.0 : (totalPaid / totalDebt) * 100;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _goBack(context),
          tooltip: 'Retour',
        ),
        title: Text(
          updateClient.name,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () =>
                context.goNamed('editclient', extra: updateClient),
            tooltip: 'Modifier',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientInfo(updateClient),
            const SizedBox(height: 20),
            _buildStats(balance, percentage, clientDebts.length),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.goNamed('ajoutdebt', extra: updateClient),
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showDeleteDialog(context, ref, updateClient),
                    icon: const Icon(Icons.delete, color: Color(0xFF003366)),
                    label: const Text(
                      "Supprimer",
                      style: TextStyle(color: Color(0xFF003366)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF003366)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                itemBuilder: (context, index) =>
                    _debtCard(context, clientDebts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo(Client client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(client.name,
            style:
            const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Téléphone : ${client.phone}"),
        const SizedBox(height: 4),
        Text("Adresse : ${client.address ?? "Non renseignée"}"),
      ],
    );
  }

  Widget _buildStats(double balance, double percentage, int debtCount) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003366).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Color(0xFF003366)),
                ),
                const SizedBox(width: 12),
                Text(
                  "Solde : ${balance.toStringAsFixed(0)} FCFA",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF003366)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Progression : ${percentage.toStringAsFixed(0)}%"),
                Text("Nombre de dettes : $debtCount"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _debtCard(BuildContext context, Debt debt) {
    final debtBalance = debt.amount - debt.paidAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
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
          "${debt.amount.toStringAsFixed(0)} FCFA",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("Solde restant : ${debtBalance.toStringAsFixed(0)} FCFA"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: debt.isPaid
                ? Colors.green.withOpacity(0.1)
                : const Color(0xFF003366).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            debt.isPaid ? "Payée" : "En attente",
            style: TextStyle(
              color: debt.isPaid ? Colors.green : const Color(0xFF003366),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () => context.goNamed(
          'details',
          pathParameters: {'id': debt.id.toString()},
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Client client) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Êtes-vous sûr de vouloir supprimer ce client ?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(clientProvider.notifier).deleteClient(client.id);
              if (context.mounted) {
                context.goNamed("clientScreen");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }
}