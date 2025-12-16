// lib/screens/dashboard_screen.dart
// ============================================================================
// Dashboard (Compte commerçant) - Vue principale après connexion
// - AppBar avec menu
// - Drawer (Gestion clients / dettes / paiements / stats / déconnexion)
// - Cartes de statistiques
// - Mini-graphique (barres simples)
// - Liste des dettes récentes (ListView)
// - FloatingActionButton pour ajouter une dette
// ============================================================================

import 'package:flutter/material.dart';
import 'package:weer_bi_dena/screens/paiements/payments_screen.dart';
import '../models/debt_model.dart';
import '../widgets/debt_card.dart';
import '../screens/clients/clients_screen.dart'; // adapte le chemin si nécessaire
// import 'debts_screen.dart';
// import 'payments_screen.dart';
import '../screens/home_screen.dart';
import 'debts/add_debt_screen.dart';
import 'debts/debts_screen.dart';
import 'notifications/notifications_screen.dart'; // pour la déconnexion / retour

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Dummy data (remplace par ton provider / service Firebase plus tard)
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
      Debt(
        clientName: "Awa Fall",
        phoneNumber: "76 555 11 22",
        amount: 20000,
        description: "Crédit farine",
        date: DateTime.now().subtract(const Duration(days: 7)),
        isPaid: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final debts = _sampleDebts();
    final totalDue =
    debts.where((d) => !d.isPaid).fold<double>(0, (s, d) => s + d.amount);
    final totalPaid =
    debts.where((d) => d.isPaid).fold<double>(0, (s, d) => s + d.amount);
    final clientsCount = 5; // placeholder, remplacer par données réelles
    final pendingCount = debts.where((d) => !d.isPaid).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A4DA1),
        title: const Text("Tableau de bord"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          // subtle background gradient to match the rest
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEEF6FF), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Greeting + small profile area
              _buildHeader(context),

              const SizedBox(height: 16),

              // Statistics cards
              Row(
                children: [
                  Expanded(child: _StatCard(
                    color: const Color(0xFF0A4DA1),
                    title: "Total dû",
                    value: "${totalDue.toStringAsFixed(0)} FCFA",
                    icon: Icons.account_balance_wallet,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    color: Colors.redAccent,
                    title: "En attente",
                    value: "$pendingCount",
                    icon: Icons.hourglass_top,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    color: Colors.green,
                    title: "Payé",
                    value: "${totalPaid.toStringAsFixed(0)} FCFA",
                    icon: Icons.check_circle,
                  )),
                ],
              ),

              const SizedBox(height: 18),

              // Mini chart + quick actions row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini chart (simple bars)
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tendance (dernières semaines)",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 80,
                              child: _MiniBarChart(
                                values: [50, 70, 40, 90, 60],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Quick actions
                ],
              ),

              const SizedBox(height: 18),

              // Recent activity title
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
                      // TODO: view all
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Voir tout")));
                    },
                    child: const Text("Voir tout"),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // List of recent debts (expand)
              Expanded(
                child: ListView.builder(
                  itemCount: debts.length,
                  itemBuilder: (context, index) {
                    final d = debts[index];
                    return DebtCard(debt: d);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating action: add debt
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A4DA1),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDebtScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0A4DA1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.storefront, color: Color(0xFF0A4DA1)),
                ),
                SizedBox(height: 12),
                Text('Boutique Jaaji',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(height: 4),
                Text('Compte commerçant',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Accueil / Statistiques"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Gestion des clients"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("Gestion des dettes"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DebtsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Gestion des paiements"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("Statistiques"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Ouvrir: Statistiques (TODO)")));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Se déconnecter",
                style: TextStyle(color: Colors.red)),
            onTap: () {
              // Logout: navigate back to Home (landing) or login
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // profile avatar
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF0A4DA1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.storefront, color: Colors.white, size: 36),
        ),
        const SizedBox(width: 12),
        // greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Bonjour,",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              SizedBox(height: 4),
              Text("Boutique Jaaji",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        // quick summary
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Clients", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text("5", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

// -------------------- Small reusable widgets --------------------

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text(value,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label, textAlign: TextAlign.center),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        elevation: 1,
        minimumSize: const Size.fromHeight(42),
      ),
      onPressed: onTap,
    );
  }
}

/// Mini bar chart: simple visual made with containers (no external package)
class _MiniBarChart extends StatelessWidget {
  final List<double> values; // values scaled 0..100

  const _MiniBarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final max = values.reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: values.map((v) {
        final heightFactor = (v / max).clamp(0.05, 1.0);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              height: 80 * heightFactor,
              decoration: BoxDecoration(
                color: const Color(0xFF0A4DA1),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
