// ============================================================================
// FICHIER : lib/widgets/debt_card.dart
// ============================================================================
// Widget d'affichage d'une dette sous forme de carte.
//
// Affiche :
//  - Nom du client + téléphone
//  - Montant dû
//  - Description
//  - Date formatée
//  - Badge statut (Payée / Impayée)
//
// MISSION : rendre l’interface claire, moderne et lisible.
// ============================================================================

import 'package:flutter/material.dart';
import '../models/debt_model.dart';
import 'package:intl/intl.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  const DebtCard({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(debt.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),

        // --------------------------------------------------------------------
        // TITRE : Nom du client + Statut
        // --------------------------------------------------------------------
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              debt.clientName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            // Badge Payé / Impayé
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: debt.isPaid ? Colors.green : Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                debt.isPaid ? "Remboursée" : "Restante",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),

        // --------------------------------------------------------------------
        // SOUS-TITRE
        // --------------------------------------------------------------------
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Numéro du client
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(debt.phoneNumber),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              debt.description,
              style: const TextStyle(color: Colors.black87),
            ),

            const SizedBox(height: 10),

            // Date
            Text(
              "Enregistré le : $formattedDate",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),

        // --------------------------------------------------------------------
        // TRAILING : Montant dû
        // --------------------------------------------------------------------
        trailing: Text(
          "${debt.amount.toStringAsFixed(0)} FCFA",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
