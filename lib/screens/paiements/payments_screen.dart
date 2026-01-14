import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/client_model.dart';
import '../../models/payment_model.dart';
import '../../widgets/payment_card.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  // État pour le filtre actif
  PaymentFilter _activeFilter = PaymentFilter.all;

  // Liste des paiements (dummy data)
  final List<Payment> _allPayments = [
    Payment(
      clientName: "Ibrahima Ndiaye",
      amount: 4000,
      date: DateTime.now().subtract(const Duration(hours: 4)),
      phoneNumber: '',
      paymentMethod: '',
    ),
    Payment(
      clientName: "Mariama Diop",
      amount: 7000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      phoneNumber: '',
      paymentMethod: '',
    ),
    Payment(
      clientName: "Ousmane Sow",
      amount: 12000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      phoneNumber: '',
      paymentMethod: '',
    ),
    Payment(
      clientName: "Fatou Dieng",
      amount: 5500,
      date: DateTime.now().subtract(const Duration(days: 3)),
      phoneNumber: '',
      paymentMethod: '',
    ),
    Payment(
      clientName: "Aminata Fall",
      amount: 8500,
      date: DateTime.now().subtract(const Duration(days: 10)),
      phoneNumber: '',
      paymentMethod: '',
    ),
  ];

  // Méthode pour filtrer les paiements
  List<Payment> get _filteredPayments {
    final now = DateTime.now();
    switch (_activeFilter) {
      case PaymentFilter.today:
        return _allPayments.where((payment) {
          return payment.date.year == now.year &&
              payment.date.month == now.month &&
              payment.date.day == now.day;
        }).toList();

      case PaymentFilter.thisWeek:
        final weekAgo = now.subtract(const Duration(days: 7));
        return _allPayments.where((payment) {
          return payment.date.isAfter(weekAgo);
        }).toList();

      case PaymentFilter.thisMonth:
        return _allPayments.where((payment) {
          return payment.date.year == now.year &&
              payment.date.month == now.month;
        }).toList();

      case PaymentFilter.all:
      default:
        return _allPayments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayments = _filteredPayments;

    // Calcul des statistiques BASÉES SUR LE FILTRE ACTIF
    final totalAmount = filteredPayments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final todayCount = filteredPayments
        .where((p) => p.date.day == DateTime.now().day)
        .length;

    return Scaffold(
      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E40AF)),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text(
          "Historique des Paiements",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF64748B)),
            onPressed: () {},
            tooltip: 'Exporter',
          ),
        ],
      ),

      // ================= BODY =================
      body: Stack(
        children: [
          // ========== FOND BLEU CLAIR SUR LES CÔTÉS ==========
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE0F2FE),
          ),

          // ========== PARTIE CENTRALE BLANCHE COURBÉE ==========
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // ========== EN-TÊTE STATISTIQUES ==========
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF60A5FA),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Vos Paiements",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${filteredPayments.length} transactions",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.attach_money,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ========== STATISTIQUES RAPIDES ==========
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Total perçu
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Color(0xFF16A34A),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Total perçu",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${totalAmount.toStringAsFixed(0)} FCFA",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),

                        // Filtre actif
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.filter_alt,
                                color: Color(0xFFD97706),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Filtre",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activeFilter.displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),

                        // Moyenne
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.trending_up,
                                color: Color(0xFF0EA5E9),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Moyenne",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              filteredPayments.isNotEmpty
                                  ? "${(totalAmount / filteredPayments.length).toStringAsFixed(0)} FCFA"
                                  : "0 FCFA",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0EA5E9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ========== BARRE DE FILTRES DYNAMIQUE ==========
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFilterChip(
                            "Tous",
                            _activeFilter == PaymentFilter.all,
                                () => _setActiveFilter(PaymentFilter.all),
                          ),
                          _buildFilterChip(
                            "Aujourd'hui",
                            _activeFilter == PaymentFilter.today,
                                () => _setActiveFilter(PaymentFilter.today),
                          ),
                          _buildFilterChip(
                            "Cette semaine",
                            _activeFilter == PaymentFilter.thisWeek,
                                () => _setActiveFilter(PaymentFilter.thisWeek),
                          ),
                          _buildFilterChip(
                            "Ce mois",
                            _activeFilter == PaymentFilter.thisMonth,
                                () => _setActiveFilter(PaymentFilter.thisMonth),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ========== LISTE DES PAIEMENTS FILTRÉS ==========
                  Expanded(
                    child: filteredPayments.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Aucun paiement ${_activeFilter == PaymentFilter.all ? '' : _activeFilter.displayName.toLowerCase()}",
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.go('/ajoutpayement'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Ajouter un paiement",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = filteredPayments[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: PaymentCard(payment: payment),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // ================= FAB =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: () => context.go('/ajoutpayement'),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Ajouter un paiement',
      ),
    );
  }

  // ========== MÉTHODE POUR CHANGER LE FILTRE ==========
  void _setActiveFilter(PaymentFilter filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  // ========== WIDGET FILTER CHIP DYNAMIQUE ==========
  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF3B82F6) : Colors.grey.shade300,
            width: isActive ? 0 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ========== ENUM POUR LES FILTRES ==========
enum PaymentFilter {
  all,
  today,
  thisWeek,
  thisMonth;

  String get displayName {
    switch (this) {
      case PaymentFilter.all:
        return "Tous";
      case PaymentFilter.today:
        return "Aujourd'hui";
      case PaymentFilter.thisWeek:
        return "Cette semaine";
      case PaymentFilter.thisMonth:
        return "Ce mois";
    }
  }
}