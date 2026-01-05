import 'package:flutter/material.dart';
import '../models/client_model.dart';

class ClientCard extends StatelessWidget {
  final Client client;

  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(client.name),
        subtitle: Text("Téléphone : ${client.phone}"),
        trailing: Text(
          "${client.totalDebt} FCFA",
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
