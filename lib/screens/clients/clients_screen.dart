// ============================================================================
// FICHIER : lib/screens/clients_screen.dart
// ============================================================================
import 'package:flutter/material.dart';
import '../../models/client_model.dart';
import '../../widgets/client_card.dart';
import 'add_client_screen.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DUMMY CLIENTS ---
    final List<Client> dummyClients = [
      Client(name: "Ibrahima Ndiaye", phone: "774512233", totalDebt: 8500),
      Client(name: "Mariama Diop", phone: "781234567", totalDebt: 12000),
      Client(name: "Ousmane Sow", phone: "701112233", totalDebt: 4500),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Clients"),
      ),
      body: ListView.builder(
        itemCount: dummyClients.length,
        itemBuilder: (context, index) {
          return ClientCard(client: dummyClients[index]);
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddClientScreen()),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
