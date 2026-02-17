import 'package:flutter/material.dart';
import '../../models/client_model.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback? onTap;

  const ClientCard({super.key, required this.client, this.onTap});

  double get totalDebt =>
      client.debts.fold(0, (sum, d) => sum + d.amount - d.paidAmount);

  @override
  Widget build(BuildContext context) {
    final balance = totalDebt;

    Color avatarColor;
    if (balance == 0) {
      avatarColor = Colors.green;
    } else if (balance > 0) {
      avatarColor = Colors.red;
    } else {
      avatarColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(client.name),
        subtitle: Text(client.phone),
        trailing: Text(
          "${balance.toStringAsFixed(0)} FCFA",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        onTap: onTap ?? () => print("Voir détails client"),
      ),
    );
  }
}
