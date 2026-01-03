import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/client_model.dart';
import '../clients/infos_client_screen.dart';
import '../../repositories/auth_repository.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐ LISTE DES CLIENTS FACTICES
    final List<Client> clients = [
      Client(
        name: "Ibrahima Ndiaye",
        phone: "774512233",
        address: "Guédiawaye",
        debts: [],
        id: '',
        product: '',
        quantity: '',
        amountDue: null,
        amountPaid: null,
      ),
      Client(
        name: "Mariama Diop",
        phone: "781234567",
        address: "Dakar",
        debts: [],
        id: '',
        product: '',
        quantity: '',
        amountDue: null,
        amountPaid: null,
      ),
      Client(
        name: "Ousmane Sow",
        phone: "701112233",
        address: "Pikine",
        debts: [],
        id: '',
        product: '',
        quantity: '',
        amountDue: null,
        amountPaid: null,
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Liste des Clients",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ================= DRAWER =================
      drawer: _buildDrawer(context, ref),

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
                  child: ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF7B2FF7),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(client.name),
                          subtitle: Text(client.phone),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            context.goNamed(
                              'infosclients', // doit correspondre au name de GoRoute
                              extra: client,   // passe l'objet client
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ================= FAB =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7B2FF7),
        onPressed: () {
          context.go('/addclient'); // naviguer vers l'ajout de client
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= DRAWER =================
  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7B2FF7),
                  Color(0xFF9F44D3),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.storefront, color: Color(0xFF7B2FF7)),
                ),
                SizedBox(height: 12),
                Text(
                  "Boutique Jaaji",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  "Compte commerçant",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Tableau de bord"),
            onTap: () => context.go('/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Clients"),
            onTap: () => context.go('/clientScreen'),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Paiements"),
            onTap: () => context.go('/payment'),
          ),
          const Divider(),

          // 🔴 BOUTON DE DÉCONNEXION
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Se déconnecter",
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              try {
                final authRepo = ref.read(authRepositoryProvider);
                await authRepo.signOut();
                // GoRouter redirige automatiquement vers login grâce au StreamProvider
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur lors de la déconnexion : $e")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
