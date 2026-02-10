import 'package:flutter/material.dart';
import '../../models/payment_model.dart';
import 'package:intl/intl.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;

  const PaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy HH:mm').format(payment.paidAt);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.payment, color: Colors.green),
        title: Text("Dette #${payment.debtId}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Payé le : $date"),
            if (payment.method != null)
              Text("Méthode : ${payment.method}"),
          ],
        ),
        trailing: Text(
          "${payment.amount.toStringAsFixed(0)} FCFA",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
