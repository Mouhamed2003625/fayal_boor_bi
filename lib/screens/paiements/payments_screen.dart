import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/payment_card.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  final int debtId; // ✅ IMPORTANT

  const PaymentsScreen({super.key, required this.debtId});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  PaymentFilter _activeFilter = PaymentFilter.all;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier)
          .loadPayments(widget.debtId);
    });
  }

  List<Payment> _filterPayments(List<Payment> payments) {
    final now = DateTime.now();

    List<Payment> filtered;

    switch (_activeFilter) {
      case PaymentFilter.today:
        filtered = payments.where((p) =>
        p.paymentDate.year == now.year &&
            p.paymentDate.month == now.month &&
            p.paymentDate.day == now.day).toList();
        break;

      case PaymentFilter.thisWeek:
        filtered = payments.where((p) =>
            p.paymentDate.isAfter(
                now.subtract(const Duration(days: 7)))).toList();
        break;

      case PaymentFilter.thisMonth:
        filtered = payments.where((p) =>
        p.paymentDate.year == now.year &&
            p.paymentDate.month == now.month).toList();
        break;

      case PaymentFilter.all:
      default:
        filtered = payments;
    }

    // ✅ tri par date décroissante
    filtered.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final payments = _filterPayments(paymentState.payments);

    final totalAmount =
    payments.fold<double>(0, (sum, p) => sum + p.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des paiements"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // ✅ plus propre
        ),
        actions: [
          PopupMenuButton<PaymentFilter>(
            onSelected: (f) =>
                setState(() => _activeFilter = f),
            itemBuilder: (_) => PaymentFilter.values
                .map((f) => PopupMenuItem(
              value: f,
              child: Text(f.displayName),
            ))
                .toList(),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: paymentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : paymentState.error != null
          ? Center(child: Text('Erreur: ${paymentState.error}'))
          : payments.isEmpty
          ? const Center(child: Text("Aucun paiement"))
          : Column(
        children: [

          /// ✅ TOTAL EN HAUT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Text(
              "Total : ${totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (_, i) =>
                  PaymentCard(payment: payments[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push('/ajoutpayement/${widget.debtId}'),
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
