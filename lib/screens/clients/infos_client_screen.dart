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
      extendBodyBehindAppBar: true,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/clientScreen');
          },
        ),
        title: const Text(
          "Informations Client",
          style: TextStyle(color: Colors.white),
        ),
      ),

      // ================= BODY =================
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7B2FF7),
              Color(0xFF9F44D3),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // -------- HEADER --------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Bonjour,",
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(
                            client.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------- CONTENT --------
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ListView(
                    children: [
                      // ---------------- FICHE CLIENT ----------------
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Color(0xFF7B2FF7),
                                    child: Icon(Icons.person,
                                        color: Colors.white, size: 32),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        client.name,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(client.phone,
                                          style: const TextStyle(
                                              color: Colors.black54)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 20, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      client.address.isEmpty
                                          ? "Aucune adresse"
                                          : client.address,
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Montant total dû :",
                                      style: TextStyle(fontSize: 16)),
                                  Text(
                                    "${totalDue.toStringAsFixed(0)} FCFA",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.goNamed('editsclients',
                                      extra: client);
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text(
                                    "Modifier les informations"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xE2FFFFFF),
                                  minimumSize: const Size.fromHeight(45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ---------------- DETTES DU CLIENT ----------------
                      const Text("Dettes du client",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      ...client.debts.map((d) {
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.money,
                              color: d.isPaid ? Colors.green : Colors.redAccent,
                            ),
                            title: Text("${d.amount.toStringAsFixed(0)} FCFA"),
                            subtitle: Text(d.description),
                            trailing: Text(
                              d.isPaid ? "Payée" : "Impayée",
                              style: TextStyle(
                                color:
                                d.isPaid ? Colors.green : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ================= FAB =================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/ajoutpayement',
          extra: client,
          ); // redirige vers ajout de paiement
        },
        icon: const Icon(Icons.payment),
        label: const Text("Ajouter un paiement"),
        backgroundColor: const Color(0xF4050505),
      ),
    );
  }
}
