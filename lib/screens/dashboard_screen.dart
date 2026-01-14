import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/debt_model.dart';
import '../providers/debt_provider.dart';
import '../repositories/auth_repository.dart';
import '../widgets/debt_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtListProvider);

    return debtsAsync.when(
      data: (debts) {
        // Calcul des métriques pour le dashboard
        final totalDue = debts.where((d) => !d.isPaid).fold<double>(0, (s, d) => s + d.amount);
        final totalPaid = debts.where((d) => d.isPaid).fold<double>(0, (s, d) => s + d.amount);
        final pendingCount = debts.where((d) => !d.isPaid).length;
        final paidCount = debts.where((d) => d.isPaid).length;
        final totalDebts = debts.length;

        // Calcul taux recouvrement
        final recoveryRate = totalDebts > 0 ? (paidCount / totalDebts * 100) : 0;

        // Dettes par statut pour le graphique
        final overdueDebts = debts.where((d) => !d.isPaid && d.dates.isBefore(DateTime.now())).length;
        final dueThisWeek = debts.where((d) => !d.isPaid && d.dates.difference(DateTime.now()).inDays <= 7).length;

        // Top 3 débiteurs
        final topDebtors = debts.where((d) => !d.isPaid).toList()
          ..sort((a, b) => b.amount.compareTo(a.amount))
          ..take(3);

        return Scaffold(
          backgroundColor: Colors.white70,
          appBar: AppBar(
            backgroundColor: Colors.blue,
            elevation: 1,
            title: const Text(
              "Dashboard",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black54),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black54),
                onPressed: () => context.go('/notification'),
              ),
            ],
          ),
          drawer: _buildDrawer(context, ref),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Cards - Première ligne
                Row(
                  children: [
                    Expanded(child: _KPICard(
                      title: "Dettes Actives",
                      value: "$pendingCount",
                      change: "${((pendingCount/totalDebts)*100).toStringAsFixed(1)}%",
                      isPositive: false,
                      icon: Icons.account_balance_wallet,
                      color: const Color(0xFF3B82F6),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _KPICard(
                      title: "Total Créances",
                      value: "${totalDue.toStringAsFixed(0)} FCFA",
                      change: "12.5% ▲",
                      isPositive: true,
                      icon: Icons.attach_money,
                      color: const Color(0xFF10B981),
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _KPICard(
                      title: "Taux Recouvrement",
                      value: "${recoveryRate.toStringAsFixed(1)}%",
                      change: "5.3% ▲",
                      isPositive: true,
                      icon: Icons.trending_up,
                      color: const Color(0xFF8B5CF6),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _KPICard(
                      title: "Échéances Imminentes",
                      value: "$dueThisWeek",
                      change: "Cette semaine",
                      isPositive: false,
                      icon: Icons.calendar_today,
                      color: const Color(0xFFEF4444),
                    )),
                  ],
                ),
                const SizedBox(height: 24),

                // Graphiques - Deuxième ligne
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildOverviewChart(debts, totalDue, totalPaid),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildStatusChart(pendingCount, paidCount, overdueDebts),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Titre section
                const Text(
                  "Top Débiteurs",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Liste des top débiteurs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DebtorListHeader(),
                      const SizedBox(height: 8),
                      ...topDebtors.map((debt) => _DebtorListItem(debt: debt)).toList(),
                      if (topDebtors.isEmpty) const Padding(
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
                    Expanded(
                      child: _buildAlertsCard(debts),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActions(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Toutes les dettes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Toutes les Dettes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/clientScreen'),
                      child: const Text("Voir tout", style: TextStyle(color: Color(0xFF3B82F6))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Liste des dettes
                if (debts.isNotEmpty) ...debts.take(5).map((debt) => DebtCard(debt: debt)).toList(),
                if (debts.isEmpty) const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Aucune dette enregistrée", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF3B82F6),
            onPressed: () => context.go('/addClient'),
            child: const Icon(Icons.add, color: Colors.white),
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
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
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
                const Text(
                  "Boutique du peuple",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Compte commerçant",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            isActive: true,
            onTap: () => context.go('/dashboard'),
          ),
          _DrawerItem(
            icon: Icons.people,
            title: "Clients",
            onTap: () => context.go('/clientScreen'),
          ),
          _DrawerItem(
            icon: Icons.payment,
            title: "Paiements",
            onTap: () => context.go('/payment'),
          ),
          _DrawerItem(
            icon: Icons.account_balance_wallet,
            title: "Dettes",
            onTap: () => context.go('/debts'),
          ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewChart(List<Debt> debts, double totalDue, double totalPaid) {
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
            "Vue d'ensemble",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Total: ${(totalDue + totalPaid).toStringAsFixed(0)} FCFA",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalDue + totalPaid) * 1.2,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [BarChartRodData(toY: totalDue, color: Colors.red)],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [BarChartRodData(toY: totalPaid, color: Colors.green)],
                    showingTooltipIndicators: [0],
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt() == 0 ? "Dû" : "Payé",
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
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
            "Statut des dettes",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _StatusItem(
            label: "En attente",
            value: pending,
            color: Colors.orange,
            percentage: pending > 0 ? (pending / (pending + paid) * 100) : 0,
          ),
          _StatusItem(
            label: "Payé",
            value: paid,
            color: Colors.green,
            percentage: paid > 0 ? (paid / (pending + paid) * 100) : 0,
          ),
          _StatusItem(
            label: "En retard",
            value: overdue,
            color: Colors.red,
            percentage: overdue > 0 ? (overdue / (pending + paid) * 100) : 0,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(List<Debt> debts) {
    final overdueCount = debts.where((d) => !d.isPaid && d.dates.isBefore(DateTime.now())).length;
    final dueSoonCount = debts.where((d) => !d.isPaid && d.dates.difference(DateTime.now()).inDays <= 3).length;

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
          const SizedBox(height: 12),
          if (overdueCount > 0) _AlertItem(
            icon: Icons.warning,
            text: "$overdueCount dette(s) en retard",
            color: Colors.red,
          ),
          if (dueSoonCount > 0) _AlertItem(
            icon: Icons.notifications_active,
            text: "$dueSoonCount échéance(s) dans 3 jours",
            color: Colors.orange,
          ),
          if (overdueCount == 0 && dueSoonCount == 0) const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Aucune alerte pour le moment",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
          const SizedBox(height: 12),
          // SECTION Actions Rapides
          const SizedBox(height: 24),
          const Text(
            "Actions Rapides",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _QuickActionItem(
                icon: Icons.add,
                label: "Nouveau client",
                onTap: (context) => context.go('/addclient'),
              ),
              _QuickActionItem(
                icon: Icons.payment,
                label: "Nouveau paiement",
                onTap: (context) => context.go('/ajoutpayement'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Composants helper
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final Color? color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.isActive = false,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? (isActive ? const Color(0xFF3B82F6) : Colors.grey[700])),
      title: Text(title, style: TextStyle(
        color: color ?? (isActive ? const Color(0xFF3B82F6) : Colors.grey[700]),
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      )),
      tileColor: isActive ? const Color(0xFF3B82F6).withOpacity(0.1) : null,
      onTap: onTap,
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final double percentage;

  const _StatusItem({
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text("$value (${percentage.toStringAsFixed(1)}%)",
                  style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _AlertItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 14))),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function(BuildContext) onTap; // ← Fonction qui prend BuildContext

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context), // ← Passer le context ici
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtorListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          flex: 2,
          child: Text("Client", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        Expanded(
          child: Text("Montant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        Expanded(
          child: Text("Jours", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }
}

class _DebtorListItem extends StatelessWidget {
  final Debt debt;

  const _DebtorListItem({required this.debt});

  @override
  Widget build(BuildContext context) {
    final daysOverdue = DateTime.now().difference(debt.dates).inDays;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(debt.clientName, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: Text("${debt.amount.toStringAsFixed(0)} FCFA",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: daysOverdue > 30 ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "$daysOverdue",
                style: TextStyle(
                  color: daysOverdue > 30 ? Colors.red : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}