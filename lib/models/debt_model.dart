// ============================================================================
// FICHIER : lib/models/debt_model.dart
// ============================================================================
// Modèle "Debt" représentant une dette enregistrée par le commerçant.
//
// Attributs :
//  - clientName    : Nom du client
//  - phoneNumber   : Contact du client
//  - amount        : Montant de la dette
//  - description   : Détails de l'achat ou du service
//  - date          : Date à laquelle la dette a été enregistrée
//  - isPaid        : Statut de paiement
//
// Ce modèle facilite :
//  - la validation des données,
//  - la sérialisation (ex: JSON / Firebase),
//  - la structuration propre du code.
// ============================================================================

class Debt {
  final String clientName;
  final String phoneNumber;
  final double amount;
  final String description;
  final DateTime date;
  final bool isPaid;

  Debt({
    required this.clientName,
    required this.phoneNumber,
    required this.amount,
    required this.description,
    required this.date,
    required this.isPaid,
  });

  // --------------------------------------------------------------------------
  // Conversion en Map (ex: stockage Firebase / SQLite)
  // --------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      "clientName": clientName,
      "phoneNumber": phoneNumber,
      "amount": amount,
      "description": description,
      "date": date.toIso8601String(),
      "isPaid": isPaid,
    };
  }

  // --------------------------------------------------------------------------
  // Conversion depuis Map
  // --------------------------------------------------------------------------
  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      clientName: map["clientName"],
      phoneNumber: map["phoneNumber"],
      amount: (map["amount"] as num).toDouble(),
      description: map["description"],
      date: DateTime.parse(map["date"]),
      isPaid: map["isPaid"],
    );
  }
}
