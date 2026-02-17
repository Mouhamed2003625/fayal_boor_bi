import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/debt_model.dart';
import '../../models/payment_model.dart';
import '../../providers/debt_provider.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/debt_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Charge les dettes une seule fois
    Future.microtask(() => ref.read(debtProvider.notifier).loadDebts());
  }

  @override
  Widget build(BuildContext context) {
    final debtState = ref.watch(debtProvider);
    final debts = debtState.debts;
    final isLoading = debtState.isLoading;
    final error = debtState.error;

    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text("Erreur : $error"));

    // Totaux et KPI
    final totalPaid = debts.fold<double>(0, (sum, d) => sum + d.paidAmount);
    final totalDue = debts.fold<double>(0, (sum, d) => sum + (d.amount - d.paidAmount));
    final pendingCount = debts.where((d) => !d.isPaid).length;
    final paidCount = debts.where((d) => d.isPaid).length;
    final totalDebts = debts.length;
    final recoveryRate = totalDebts > 0 ? (paidCount / totalDebts * 100) : 0;

    final overdueDebts = debts.where((d) => !d.isPaid && d.dueDate.isBefore(DateTime.now())).length;
    final dueThisWeek = debts.where((d) {
      if (d.isPaid) return false;
      final daysUntilDue = d.dueDate.difference(DateTime.now()).inDays;
      return daysUntilDue >= 0 && daysUntilDue <= 7;
    }).length;

    final topDebtors = debts.where((d) => !d.isPaid).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 1,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black54), onPressed: () {}),
        ],
      ),
      drawer: _buildDrawer(context, ref),
      body: RefreshIndicator(
        onRefresh: () async => await ref.read(debtProvider.notifier).loadDebts(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _KPICard(
                      title: "Dettes Actives",
                      value: "$pendingCount",
                      change: totalDebts > 0
                          ? "${((pendingCount / totalDebts) * 100).toStringAsFixed(1)}%"
                          : "0%",
                      isPositive: false,
                      icon: Icons.account_balance_wallet,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KPICard(
                      title: "Total Créances",
                      value: "${totalDue.toStringAsFixed(0)} FCFA",
                      change: "▲",
                      isPositive: true,
                      icon: Icons.attach_money,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _KPICard(
                      title: "Taux Recouvrement",
                      value: "${recoveryRate.toStringAsFixed(1)}%",
                      change: "▲",
                      isPositive: true,
                      icon: Icons.trending_up,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KPICard(
                      title: "Échéances Imminentes",
                      value: "$dueThisWeek",
                      change: "Cette semaine",
                      isPositive: false,
                      icon: Icons.calendar_today,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Graphiques
              Row(
                children: [
                  Expanded(flex: 2, child: _buildOverviewChart(totalDue, totalPaid)),
                  const SizedBox(width: 12),
                  Expanded(flex: 1, child: _buildStatusChart(pendingCount, paidCount, overdueDebts)),
                ],
              ),
              const SizedBox(height: 24),

              // Top Débiteurs
              const Text(
                "Top Débiteurs",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const _DebtorListHeader(),
                    const SizedBox(height: 8),
                    ...topDebtors.take(3).map((debt) => _DebtorListItem(debt: debt)),
                    if (topDebtors.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("Aucune dette active", style: TextStyle(color: Colors.grey)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Alertes & Actions
              Row(
                children: [
                  Expanded(child: _buildAlertsCard(debts)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildQuickActions(context)),
                ],
              ),
              const SizedBox(height: 24),

              // Toutes les dettes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Toutes les Dettes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () => context.go('/clientScreen'),
                    child: const Text("Voir tout", style: TextStyle(color: Color(0xFF3B82F6))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (debts.isNotEmpty)
                ...debts.take(5).map(
                      (debt) => DebtCard(
                    debt: debt,
                    onTap: () => context.goNamed('debt-details', extra: debt),
                  ),
                ),
              if (debts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Aucune dette enregistrée", style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: () => context.go('/addClient'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ------------------- Drawer -------------------
  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.storefront, color: Color(0xFF3B82F6), size: 32),
                ),

                const SizedBox(height: 12),
                const Text("Boutique du peuple", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const Text("Compte commerçant", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _DrawerItem(icon: Icons.dashboard, title: "Dashboard", isActive: true, onTap: () => context.go('/dashboard')),
          _DrawerItem(icon: Icons.people, title: "Clients", onTap: () => context.go('/clientScreen')),
          _DrawerItem(icon: Icons.account_balance_wallet, title: "Dettes", onTap: () => context.go('/debts')),
          _DrawerItem(icon: Icons.money, title: "Payments", onTap: () => context.goNamed('ajoutpayement')),

          const Divider(),
          _DrawerItem(
            icon: Icons.logout,
            title: "Se déconnecter",
            color: Colors.red,
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

  // ------------------- KPI Card -------------------
  Widget _KPICard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            Text(change, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(List<Debt> debts) {
    final now = DateTime.now();

    final overdue = debts.where((d) =>
    !d.isPaid && d.dueDate.isBefore(now)).length;

    final dueThisWeek = debts.where((d) {
      if (d.isPaid) return false;
      final days = d.dueDate.difference(now).inDays;
      return days >= 0 && days <= 7;
    }).length;

    final active = debts.where((d) => !d.isPaid).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Alertes",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _alertRow("En retard", overdue, Colors.red),
          const SizedBox(height: 8),
          _alertRow("Cette semaine", dueThisWeek, Colors.orange),
          const SizedBox(height: 8),
          _alertRow("Actives", active, Colors.blue),
        ],
      ),
    );
  }

  Widget _alertRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          "$value",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }


  Widget _buildQuickActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Actions rapides",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _quickButton(
            icon: Icons.person_add,
            label: "Nouveau client",
            color: const Color(0xFF3B82F6),
            onTap: () => context.go('/addClient'),
          ),
          const SizedBox(height: 12),
          _quickButton(
            icon: Icons.add_card,
            label: "Nouvelle dette",
            color: Colors.orange,
            onTap: () => context.go('/debts'),
          ),
          const SizedBox(height: 12),

        ],
      ),
    );
  }

  Widget _quickButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isActive;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? (isActive ? const Color(0xFF3B82F6) : Colors.black87);

    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title,
        style: TextStyle(
          color: itemColor,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}


// ------------------- Graphiques -------------------
Widget _buildOverviewChart(double totalDue, double totalPaid) {
  final maxY = (totalDue + totalPaid) * 1.2;
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Vue d'ensemble", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Total: ${(totalDue + totalPaid).toStringAsFixed(0)} FCFA", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalDue, color: Colors.red)], showingTooltipIndicators: [0]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalPaid, color: Colors.green)], showingTooltipIndicators: [0]),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text("Dû", style: TextStyle(fontSize: 12));
                        case 1:
                          return const Text("Payé", style: TextStyle(fontSize: 12));
                        default:
                          return const Text("");
                      }
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatusChart(int pending, int paid, int overdue) {
  final total = pending + paid + overdue;
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Statut des dettes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _StatusItem(label: "En attente", value: pending, percentage: total > 0 ? (pending / total * 100) : 0, color: Colors.orange),
        _StatusItem(label: "Payé", value: paid, percentage: total > 0 ? (paid / total * 100) : 0, color: Colors.green),
        _StatusItem(label: "En retard", value: overdue, percentage: total > 0 ? (overdue / total * 100) : 0, color: Colors.red),
      ],
    ),
  );
}

// ------------------- Status Item -------------------
class _StatusItem extends StatelessWidget {
  final String label;
  final int value;
  final double percentage;
  final Color color;

  const _StatusItem({required this.label, required this.value, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label),
            Text("$value (${percentage.toStringAsFixed(1)}%)"),
          ]),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            color: color,
            backgroundColor: Colors.grey[200],
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

// ------------------- Alerts & Quick Actions -------------------
// ... (idem à ton code, avec routes corrigées) ...

// ------------------- Debtor List -------------------
class _DebtorListHeader extends StatelessWidget {
  const _DebtorListHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(flex: 3, child: Text("Client", style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 2, child: Text("Montant", style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 2, child: Text("Échéance", style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 1, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }
}

class _DebtorListItem extends StatelessWidget {
  final Debt debt;
  const _DebtorListItem({required this.debt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(debt.client?.name ?? "Client ${debt.clientId}")),
          Expanded(flex: 2, child: Text("${debt.amount.toStringAsFixed(0)} FCFA")),
          Expanded(
            flex: 2,
            child: Text("${debt.dueDate.day.toString().padLeft(2,'0')}/${debt.dueDate.month.toString().padLeft(2,'0')}/${debt.dueDate.year}"),
          ),
          Expanded(
            flex: 1,
            child: Icon(debt.isPaid ? Icons.check_circle : Icons.pending, color: debt.isPaid ? Colors.green : Colors.orange),
          ),
        ],
      ),
    );
  }
}
