import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/debt_model.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback onTap;

  const DebtCard({super.key, required this.debt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedDate = debt.payments.isNotEmpty
        ? DateFormat('dd MMM yyyy, HH:mm').format(debt.payments.last.paymentDate)
        : 'Non payée';

    final balance = debt.amount - debt.paidAmount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Dette #${debt.id} - Client ${debt.clientId}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text("Produit: ${debt.product}"),
              Text("Quantité: ${debt.quantity}"),
              Text("Montant dû: ${debt.amount.toStringAsFixed(0)} FCFA"),
              Text("Payé: ${debt.paidAmount.toStringAsFixed(0)} FCFA"),
              Text(balance == 0 ? "Soldé" : "Solde restant: ${balance.toStringAsFixed(0)} FCFA",
                  style: TextStyle(
                      color: balance > 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              if (!debt.isPaid && balance > 0)
                Text(
                  "En retard",
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          trailing: Text(
            "${debt.amount.toStringAsFixed(0)} FCFA",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
