import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';
import '../models/debt_model.dart';
import '../widgets/debt_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // ---------------- Dummy data ----------------
  List<Debt> _sampleDebts() {
    return [
      Debt(
        clientName: "Ibrahima Ndiaye",
        phoneNumber: "77 451 22 33",
        amount: 8500,
        description: "Achat riz + huile",
        date: DateTime.now().subtract(const Duration(days: 1)),
        isPaid: false,
      ),
      Debt(
        clientName: "Mariama Diop",
        phoneNumber: "78 123 45 67",
        amount: 12000,
        description: "Crédit sucre + lait",
        date: DateTime.now().subtract(const Duration(hours: 5)),
        isPaid: false,
      ),
      Debt(
        clientName: "Ousmane Sow",
        phoneNumber: "70 111 22 33",
        amount: 4500,
        description: "Pain + café",
        date: DateTime.now().subtract(const Duration(days: 3)),
        isPaid: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = _sampleDebts();
    final totalDue =
    debts.where((d) => !d.isPaid).fold<double>(0, (s, d) => s + d.amount);
    final totalPaid =
    debts.where((d) => d.isPaid).fold<double>(0, (s, d) => s + d.amount);
    final pendingCount = debts.where((d) => !d.isPaid).length;

    return Scaffold(
      extendBodyBehindAppBar: true,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Tableau de bord",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              context.go('/notification');
            },
          ),
        ],
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

              // -------- HEADER (violet) --------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildHeader(),
              ),

              const SizedBox(height: 20),

              // -------- CONTENT (white card) --------
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      // -------- STATS --------
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              color: const Color(0xFF7B2FF7),
                              title: "Total dû",
                              value: "${totalDue.toStringAsFixed(0)} FCFA",
                              icon: Icons.account_balance_wallet,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              color: Colors.redAccent,
                              title: "En attente",
                              value: "$pendingCount",
                              icon: Icons.hourglass_top,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              color: Colors.green,
                              title: "Payé",
                              value: "${totalPaid.toStringAsFixed(0)} FCFA",
                              icon: Icons.check_circle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // -------- RECENT --------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Activités récentes",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/clientScreen');
                            },
                            child: const Text("Voir tout"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Expanded(
                        child: ListView.builder(
                          itemCount: debts.length,
                          itemBuilder: (context, index) {
                            return DebtCard(debt: debts[index]);
                          },
                        ),
                      ),
                    ],
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
          context.go('/addclient');
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
                  "Boutique du peuple",
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
                // GoRouter redirigera automatiquement vers login
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

  // ================= HEADER =================
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.storefront,
              color: Colors.white, size: 36),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bonjour,", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 4),
              Text(
                "Boutique du peuple",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================= STAT CARD =================
class _StatCard extends StatelessWidget {
  final Color color;
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.color,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
