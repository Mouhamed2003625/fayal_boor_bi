import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/client_model.dart';
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
        date: DateTime.now().subtract(const Duration(hours: 4)), phoneNumber: '', paymentMethod: '',
      ),
      Payment(
        clientName: "Mariama Diop",
        amount: 7000,
        date: DateTime.now().subtract(const Duration(days: 1)), phoneNumber: '', paymentMethod: '',
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/dashboard');
          },
        ),
        title: const Text(
          "Historique des Paiements",
          style: TextStyle(color: Colors.white),
        ),
      ),


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

              // -------- HEADER --------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.payment,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Historique des Paiements",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------- CONTENT --------
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: dummyPayments.length,
                    itemBuilder: (context, index) =>
                        PaymentCard(payment: dummyPayments[index]),
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
          context.go('/ajoutpayement');
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un paiement',
      ),


    );
  }



}
