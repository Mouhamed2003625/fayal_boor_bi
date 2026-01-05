import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import 'package:intl/intl.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;

  const PaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("dd MMM yyyy HH:mm").format(payment.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.payment, color: Colors.green, size: 30),
        title: Text("${payment.clientName}"),
        subtitle: Text("Payé le : $formattedDate"),
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
