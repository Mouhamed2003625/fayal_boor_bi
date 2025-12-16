import 'package:flutter/material.dart';
import '../models/client_model.dart';

class ClientCard extends StatelessWidget {
  final Client client;

  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade700,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(client.name),
        subtitle: Text("Téléphone : ${client.phone}"),
        trailing: Text(
          "${client.totalDebt.toStringAsFixed(0)} FCFA",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        onTap: () => print("Voir détails client"),
      ),
    );
  }
}
