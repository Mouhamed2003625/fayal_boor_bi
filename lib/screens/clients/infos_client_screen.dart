import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/client_model.dart';
import '../../models/debt_model.dart';

class InfosClientScreen extends StatelessWidget {
  final Client client;

  const InfosClientScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    double totalDue = client.debts
        .where((d) => !d.isPaid)
        .fold(0, (s, d) => s + d.amount);

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
            onPressed: () => context.goNamed('editsclients', extra: client),
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
                        // Avatar
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
                                      client.address.isEmpty
                                          ? "Aucune adresse"
                                          : client.address,
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
                        // Total dû
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Color(0xFFDC2626),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Total dû",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${totalDue.toStringAsFixed(0)} FCFA",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),

                        // Nombre de dettes
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.list_alt,
                                color: Color(0xFFD97706),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Dettes",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${client.debts.length}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),

                        // Dettes payées
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Color(0xFF16A34A),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Payées",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${client.debts.where((d) => d.isPaid).length}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ========== LISTE DES DETTES ==========
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              "Détails des dettes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),

                          Expanded(
                            child: client.debts.isEmpty
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
                                    "Aucune dette",
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : ListView.builder(
                              itemCount: client.debts.length,
                              itemBuilder: (context, index) {
                                final debt = client.debts[index];
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
                                            : const Color(0xFFFEE2E2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        debt.isPaid
                                            ? Icons.check
                                            : Icons.access_time,
                                        color: debt.isPaid
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFDC2626),
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      "${debt.amount.toStringAsFixed(0)} FCFA",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          debt.description,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Échéance: ${debt.dates.day}/${debt.dates.month}/${debt.dates.year}",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: debt.isPaid
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFFEE2E2),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        debt.isPaid ? "Payée" : "En attente",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: debt.isPaid
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      // Option: Navigation vers détails de la dette
                                      // context.go('/debt-details', extra: debt);
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
                  // Navigation vers historique des paiements
                  context.go('/payment-history', extra: client);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.history, color: Color(0xFF3B82F6)),
                label: const Text(
                  "Historique",
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