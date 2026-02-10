import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/client_model.dart';



class InfosClientScreen extends StatelessWidget {
  final Client client;

  const InfosClientScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    // Calculs basés sur le nouveau modèle
    double totalDue = client.totalDebt; // Utilise le getter du modèle
    double totalPaid = client.totalPaid; // Utilise le getter du modèle
    double balance = client.balance; // Solde restant
    double paymentPercentage = client.paymentPercentage; // Pourcentage de paiement

    // Filtrer les dettes par clientId (au cas où il y aurait d'autres dettes)
    final clientDebts = client.debts.where((d) => d.clientId == client.id).toList();

    return Scaffold(
      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E40AF)),
          onPressed: () => context.go('/clientScreen'),
        ),
        title: Text(
          client.name,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
            onPressed: () => context.goNamed('editclient', extra: client),
          ),
        ],
      ),

      // ================= BODY =================
      body: Stack(
        children: [
          // ========== FOND BLEU CLAIR SUR LES CÔTÉS ==========
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE0F2FE), // Bleu clair uniforme
          ),

          // ========== PARTIE CENTRALE BLANCHE COURBÉE ==========
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // ========== EN-TÊTE DU CLIENT ==========
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF60A5FA),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar avec indicateur de statut
                        Stack(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            if (balance == 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF16A34A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            if (balance > 0 && clientDebts.any((d) => d.isOverdue))
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.warning,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 20),

                        // Infos client
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    client.phone,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      client.address?.isNotEmpty == true
                                          ? client.address!
                                          : "Aucune adresse",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (client.product?.isNotEmpty == true) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${client.product!} (x${client.quantity ?? '1'})",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ========== KPI DU CLIENT ==========
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Solde restant
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: balance > 0
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                balance > 0
                                    ? Icons.account_balance_wallet
                                    : Icons.check_circle,
                                color: balance > 0
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF16A34A),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              balance > 0 ? "Solde dû" : "Soldé",
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${balance.abs().toStringAsFixed(0)} FCFA",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: balance > 0
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),

                        // Pourcentage paiement
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: paymentPercentage >= 50
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFFEE2E2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                paymentPercentage >= 50
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: paymentPercentage >= 50
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFFDC2626),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Payé",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${paymentPercentage.toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: paymentPercentage >= 50
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),

                        // Dettes en retard
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: clientDebts.any((d) => d.isOverdue)
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                clientDebts.any((d) => d.isOverdue)
                                    ? Icons.warning
                                    : Icons.schedule,
                                color: clientDebts.any((d) => d.isOverdue)
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF16A34A),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Retards",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${clientDebts.where((d) => d.isOverdue).length}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: clientDebts.any((d) => d.isOverdue)
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ========== BARRE DE PROGRESSION ==========
                  if (totalDue > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Progression de paiement",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "${totalPaid.toStringAsFixed(0)}/${totalDue.toStringAsFixed(0)} FCFA",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: paymentPercentage / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              paymentPercentage >= 50
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFD97706),
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Impayé: ${balance.toStringAsFixed(0)} FCFA",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                "Payé: ${totalPaid.toStringAsFixed(0)} FCFA",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ========== LISTE DES DETTES ==========
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Historique des dettes",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              if (clientDebts.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () {
                                    // Navigation vers ajout de dette
                                    context.go('/ajoutdebt', extra: client);
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text("Nouvelle dette"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF3B82F6),
                                  ),
                                ),
                            ],
                          ),

                          Expanded(
                            child: clientDebts.isEmpty
                                ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 60,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Aucune dette enregistrée",
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      context.go('/ajoutdebt', extra: client);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF3B82F6),
                                    ),
                                    child: const Text("Ajouter une dette"),
                                  ),
                                ],
                              ),
                            )
                                : ListView.builder(
                              itemCount: clientDebts.length,
                              itemBuilder: (context, index) {
                                final debt = clientDebts[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: debt.isPaid
                                            ? const Color(0xFFDCFCE7)
                                            : debt.isOverdue
                                            ? const Color(0xFFFEE2E2)
                                            : const Color(0xFFFEF3C7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        debt.isPaid
                                            ? Icons.check
                                            : debt.isOverdue
                                            ? Icons.warning
                                            : Icons.access_time,
                                        color: debt.isPaid
                                            ? const Color(0xFF16A34A)
                                            : debt.isOverdue
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFFD97706),
                                        size: 20,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          "${debt.amount.toStringAsFixed(0)} FCFA",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        if (debt.isOverdue)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEE2E2),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              "${debt.daysOverdue}j",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFDC2626),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          debt.description,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              "Créée: ${debt.createdAt.day}/${debt.createdAt.month}/${debt.createdAt.year}",
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              "Échéance: ${debt.dueDate.day}/${debt.dueDate.month}/${debt.dueDate.year}",
                                              style: TextStyle(
                                                color: debt.isOverdue
                                                    ? const Color(0xFFDC2626)
                                                    : Colors.grey[500],
                                                fontSize: 11,
                                                fontWeight: debt.isOverdue
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // CORRECTION: Vérifier si dates n'est pas null
                                        if (debt.dates != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            "Payée: ${debt.dates!.day}/${debt.dates!.month}/${debt.dates!.year}",
                                            style: const TextStyle(
                                              color: Color(0xFF16A34A),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: debt.isPaid
                                            ? const Color(0xFFDCFCE7)
                                            : debt.isOverdue
                                            ? const Color(0xFFFEE2E2)
                                            : const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        debt.isPaid
                                            ? "Payée"
                                            : debt.isOverdue
                                            ? "En retard"
                                            : "En attente",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: debt.isPaid
                                              ? const Color(0xFF16A34A)
                                              : debt.isOverdue
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      context.goNamed(
                                        'debt-details',
                                        extra: debt,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ================= BOTTOM BAR =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigation vers ajout de dette
                  context.go('/ajoutdebt', extra: client);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_chart, color: Color(0xFF3B82F6)),
                label: const Text(
                  "Nouvelle dette",
                  style: TextStyle(color: Color(0xFF3B82F6)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/ajoutpayement', extra: client);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text(
                  "Nouveau paiement",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}