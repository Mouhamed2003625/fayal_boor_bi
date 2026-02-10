// ============================================================================
//  MODÈLE : Payment (Versement lié à une dette)
// ============================================================================

class Payment {
  /// Identifiant unique du paiement
  final int id;

  /// Clé étrangère vers la dette
  final int debtId;

  /// Montant payé
  final double amount;

  /// Date du paiement
  final DateTime paidAt;

  /// Méthode de paiement (cash, mobile money, virement…)
  final String? method;

  /// Référence de paiement (num transaction, reçu…)
  final String? reference;

  /// Notes supplémentaires
  final String? notes;

  /// Utilisateur ayant enregistré le paiement
  final String? userId;

  Payment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paidAt,
    this.method,
    this.reference,
    this.notes,
    this.userId,
  });

  // --------------------------------------------------------------------------
  // Factory : depuis JSON backend
  // --------------------------------------------------------------------------
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: int.tryParse('${json['id']}') ?? 0,
      debtId: int.tryParse('${json['debtId'] ?? json['debt_id']}') ?? 0,
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      paidAt: json['paidAt'] != null
          ? DateTime.tryParse(json['paidAt'].toString()) ?? DateTime.now()
          : (json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString()) ?? DateTime.now()
          : DateTime.now()),
      method: (json['method'] ?? json['payment_method'])?.toString(),
      reference: (json['reference'] ?? json['payment_reference'])?.toString(),
      notes: json['notes']?.toString(),
      userId: (json['userId'] ?? json['user_id'])?.toString(),
    );
  }

  // --------------------------------------------------------------------------
  // Conversion vers Map (POST backend)
  // --------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debtId': debtId,
      'amount': amount,
      'paidAt': paidAt.toIso8601String(),
      'method': method,
      'reference': reference,
      'notes': notes,
      'userId': userId,
    };
  }

  // --------------------------------------------------------------------------
  // copyWith
  // --------------------------------------------------------------------------
  Payment copyWith({
    int? id,
    int? debtId,
    double? amount,
    DateTime? paidAt,
    String? method,
    String? reference,
    String? notes,
    String? userId,
  }) {
    return Payment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      paidAt: paidAt ?? this.paidAt,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'Payment{id: $id, debtId: $debtId, amount: $amount, paidAt: $paidAt}';
  }
}
