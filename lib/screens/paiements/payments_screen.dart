import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/payment_model.dart';
import '../../widgets/payment_card.dart';


class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}



class _PaymentsScreenState extends State<PaymentsScreen> {
  PaymentFilter _activeFilter = PaymentFilter.all;

  final List<Payment> _allPayments = [
    Payment(
      id: 1,
      debtId: 101,
      amount: 4000,
      paidAt: DateTime.now().subtract(const Duration(hours: 4)),
      method: "Cash",
    ),
    Payment(
      id: 2,
      debtId: 102,
      amount: 7000,
      paidAt: DateTime.now().subtract(const Duration(days: 1)),
      method: "Wave",
    ),
    Payment(
      id: 3,
      debtId: 103,
      amount: 12000,
      paidAt: DateTime.now().subtract(const Duration(days: 2)),
      method: "Orange Money",
    ),
  ];

  List<Payment> get _filteredPayments {
    final now = DateTime.now();

    switch (_activeFilter) {
      case PaymentFilter.today:
        return _allPayments.where((p) =>
        p.paidAt.year == now.year &&
            p.paidAt.month == now.month &&
            p.paidAt.day == now.day).toList();

      case PaymentFilter.thisWeek:
        return _allPayments
            .where((p) => p.paidAt.isAfter(now.subtract(const Duration(days: 7))))
            .toList();

      case PaymentFilter.thisMonth:
        return _allPayments.where((p) =>
        p.paidAt.year == now.year &&
            p.paidAt.month == now.month).toList();

      case PaymentFilter.all:
      default:
        return _allPayments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final payments = _filteredPayments;
    final totalAmount = payments.fold<double>(0, (s, p) => s + p.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des paiements"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: payments.isEmpty
          ? const Center(child: Text("Aucun paiement"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (_, i) => PaymentCard(payment: payments[i]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/ajoutpayement'),
        child: const Icon(Icons.add),
      ),
    );
  }
}


enum PaymentFilter {
  all,
  today,
  thisWeek,
  thisMonth;

  String get displayName {
    switch (this) {
      case PaymentFilter.today:
        return "Aujourd'hui";
      case PaymentFilter.thisWeek:
        return "Cette semaine";
      case PaymentFilter.thisMonth:
        return "Ce mois";
      case PaymentFilter.all:
      default:
        return "Tous";
    }
  }
}
