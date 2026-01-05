import 'debt_model.dart';

class Client {
  String id;                 // ID unique du client (utile pour Firebase)
  String name;               // Nom complet
  String phone;              // Numéro de téléphone
  String address;            // Adresse
  String product;            // Produit vendu
  String quantity;           // Quantité du produit
  double? amountDue;          // Montant total à payer
  double? amountPaid;         // Montant déjà payé
  DateTime? paymentDate;     // Date du versement
  List<Debt> debts;          // Historique des dettes

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.product,
    required this.quantity,
    required this.amountDue,
    required this.amountPaid,
    this.paymentDate,
    this.debts = const [],
  });

  // Total des dettes impayées
  double get totalDebt {
    return debts
        .where((d) => !d.isPaid)
        .fold(0, (sum, d) => sum + d.amount);
  }

  // Montant total payé
  double get totalPaid {
    return debts
        .where((d) => d.isPaid)
        .fold(0, (sum, d) => sum + d.amount);
  }

}
