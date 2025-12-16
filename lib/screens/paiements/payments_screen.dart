// ============================================================================
// FICHIER : lib/screens/payments_screen.dart
// ============================================================================
import 'package:flutter/material.dart';
import '../../models/payment_model.dart';
import '../../widgets/payment_card.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Payment> dummyPayments = [
      Payment(
        clientName: "Ibrahima Ndiaye",
        amount: 4000,
        date: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Payment(
        clientName: "Mariama Diop",
        amount: 7000,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Historique des Paiements")),

      body: ListView.builder(
        itemCount: dummyPayments.length,
        itemBuilder: (context, index) =>
            PaymentCard(payment: dummyPayments[index]),
      ),
    );
  }
}
