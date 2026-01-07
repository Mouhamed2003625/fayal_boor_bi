// ============================================================================
// FICHIER : lib/models/payment_model.dart
// ============================================================================
// Modèle "Payment" représentant un paiement effectué par un client.
//
// Attributs :
//  - clientName      : Nom du client
//  - phoneNumber     : Contact du client
//  - amount          : Montant payé
//  - paymentMethod   : Moyen de paiement (cash, mobile money, carte, etc.)
//  - date            : Date du paiement
//
// Ce modèle facilite :
//  - la validation des données,
//  - la sérialisation (ex: JSON / Firebase),
//  - la structuration propre du code.
// ============================================================================

class Payment {
  final String clientName;
  final String phoneNumber;
  final double amount;
  final String paymentMethod;
  final DateTime date;

  Payment({
    required this.clientName,
    required this.phoneNumber,
    required this.amount,
    required this.paymentMethod,
    required this.date,
  });

  // --------------------------------------------------------------------------
  // Conversion en Map (ex: stockage Firebase / SQLite)
  // --------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      "clientName": clientName,
      "phoneNumber": phoneNumber,
      "amount": amount,
      "paymentMethod": paymentMethod,
      "date": date.toIso8601String(),
    };
  }

  // --------------------------------------------------------------------------
  // Conversion depuis Map
  // --------------------------------------------------------------------------
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      clientName: map["clientName"],
      phoneNumber: map["phoneNumber"],
      amount: (map["amount"] as num).toDouble(),
      paymentMethod: map["paymentMethod"],
      date: DateTime.parse(map["date"]),
    );
  }
}
