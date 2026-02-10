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
// MISSION : rendre l'interface claire, moderne et lisible.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/debt_model.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback onTap;

  const DebtCard({
    super.key,
    required this.debt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // CORRECTION: Gérer le cas où dates est null
    final formattedDate = debt.dates != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(debt.dates!)
        : 'Non payée';

    // Date d'échéance formatée
    final formattedDueDate = DateFormat('dd/MM/yyyy').format(debt.dueDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),

          // --------------------------------------------------------------------
          // TITRE : Nom du client + Statut
          // --------------------------------------------------------------------
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  // CORRECTION: Utiliser client?.name ou clientId
                  debt.client?.name ?? "Client ${debt.clientId}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
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
                  Text(debt.client?.phone ?? "Tél: non disponible"),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                debt.description,
                style: const TextStyle(color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // Dates importantes
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Échéance: $formattedDueDate",
                    style: TextStyle(
                      color: debt.isOverdue ? Colors.red : Colors.grey,
                      fontSize: 12,
                      fontWeight: debt.isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    debt.isPaid
                        ? "Payé le: $formattedDate"
                        : "Non payée",
                    style: TextStyle(
                      color: debt.isPaid ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  if (debt.isOverdue && !debt.isPaid) ...[
                    const SizedBox(height: 4),
                    Text(
                      "En retard de ${debt.daysOverdue} jour${debt.daysOverdue > 1 ? 's' : ''}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // --------------------------------------------------------------------
          // TRAILING : Montant dû
          // --------------------------------------------------------------------
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${debt.amount.toStringAsFixed(0)} FCFA",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              if (debt.isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "RETARD",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}