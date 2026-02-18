import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/payment_provider.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  static const Color primaryBlue = Color(0xFF003366);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier).loadAllPayments();
    });
  }

  /// Fonction pour gérer le retour à la page précédente
  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
            tooltip: 'Retour',
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
            tooltip: 'Retour',
          ),
          title: const Text(
            "Paiements",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(child: Text("Erreur: ${state.error}")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _goBack,
          tooltip: 'Retour',
        ),
        title: const Text(
          "Tous les paiements",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.read(paymentProvider.notifier).loadAllPayments(),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, primaryBlue.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: state.payments.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 20),
              const Text(
                "Aucun paiement enregistré",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        )
            : RefreshIndicator(
          onRefresh: () async => ref.read(paymentProvider.notifier).loadAllPayments(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.payments.length,
            itemBuilder: (context, index) {
              final p = state.payments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.payment, color: primaryBlue),
                  ),
                  title: Text(
                    "${p.amount.toStringAsFixed(0)} FCFA",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Client: ${p.clientName ?? 'Inconnu'}"),
                      Text("Produit: ${p.product ?? 'Inconnu'}"),
                      Text("Date: ${p.paymentDate.toLocal().toString().split(' ')[0]}"),
                      if (p.method != null && p.method!.isNotEmpty)
                        Text("Méthode: ${p.method}"),
                      if (p.notes != null && p.notes!.isNotEmpty)
                        Text("Notes: ${p.notes}"),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}