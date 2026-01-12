import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/debt_model.dart';
import '../providers/debt_provider.dart';
import '../widgets/debt_card.dart';
import '../repositories/auth_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtListProvider);

    return debtsAsync.when(
      data: (debts) {
        final totalDue =
        debts.where((d) => !d.isPaid).fold<double>(0, (s, d) => s + d.amount);
        final totalPaid =
        debts.where((d) => d.isPaid).fold<double>(0, (s, d) => s + d.amount);
        final pendingCount = debts.where((d) => !d.isPaid).length;

        // Préparer les données pour le graphique
        final barGroups = debts.asMap().entries.map((entry) {
          final index = entry.key.toDouble();
          final debt = entry.value;
          return BarChartGroupData(
            x: index.toInt(),
            barRods: [
              BarChartRodData(
                toY: debt.amount,
                color: debt.isPaid ? Colors.green : Colors.red,
              ),
            ],
          );
        }).toList();

        return Scaffold(
          extendBodyBehindAppBar: true,
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
                onPressed: () => context.go('/notification'),
              ),
            ],
          ),
          drawer: _buildDrawer(context, ref),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B2FF7), Color(0xFF9F44D3), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildHeader(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        children: [
                          // STATS + BAR CHART
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  color: Colors.redAccent,
                                  title: "Total dû",
                                  value: "${totalDue.toStringAsFixed(0)} FCFA",
                                  icon: Icons.account_balance_wallet,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  color: Colors.orange,
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

                          // BAR CHART
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: debts
                                    .map((d) => d.amount)
                                    .fold<double>(0, (prev, e) => e > prev ? e : prev) *
                                    1.2,
                                barGroups: barGroups,
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx >= 0 && idx < debts.length) {
                                          final d = debts[idx];
                                          return Text(
                                              "${d.dates.day}/${d.dates.month}",
                                              style:
                                              const TextStyle(fontSize: 10));
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // RECENT ACTIVITY
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Activités récentes",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () => context.go('/clientScreen'),
                                child: const Text("Voir tout"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // LISTE DES DETTES
                          Expanded(
                            child: ListView.builder(
                              itemCount: debts.length,
                              itemBuilder: (context, index) =>
                                  DebtCard(debt: debts[index]),
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF7B2FF7),
            onPressed: () => context.go('/addclient'),
            child: const Icon(Icons.add),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Erreur : $e")),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B2FF7), Color(0xFF9F44D3)],
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
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Dettes"),
            onTap: () => context.go('/debts'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Se déconnecter", style: TextStyle(color: Colors.red)),
            onTap: () async {
              try {
                final authRepo = ref.read(authRepositoryProvider);
                await authRepo.signOut();
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
          child: const Icon(Icons.storefront, color: Colors.white, size: 36),
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

class _StatCard extends StatelessWidget {
  final Color color;
  final String title;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.color,
        required this.title,
        required this.value,
        required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
