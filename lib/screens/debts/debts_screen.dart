// ============================================================================
// FICHIER : lib/screens/debts_screen.dart
// ============================================================================
import 'package:flutter/material.dart';
import '../../models/debt_model.dart';
import '../../widgets/debt_card.dart';
import 'add_debt_screen.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Debt> dummyDebts = [
      Debt(
        clientName: "Ibrahima Ndiaye",
        phoneNumber: "774512233",
        amount: 8500,
        description: "Achat riz + huile",
        date: DateTime.now().subtract(const Duration(days: 1)),
        isPaid: false,
      ),
      Debt(
        clientName: "Mariama Diop",
        phoneNumber: "781234567",
        amount: 12000,
        description: "Crédit sucre + lait",
        date: DateTime.now().subtract(const Duration(hours: 5)),
        isPaid: false,
      ),
      Debt(
        clientName: "Ousmane Sow",
        phoneNumber: "701112233",
        amount: 4500,
        description: "Pain + café Touba",
        date: DateTime.now().subtract(const Duration(days: 3)),
        isPaid: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des Dettes"),
      ),
      body: ListView.builder(
        itemCount: dummyDebts.length,
        itemBuilder: (context, index) => DebtCard(debt: dummyDebts[index]),
      ),
      floatingActionButton: FloatingActionButton(
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
}
