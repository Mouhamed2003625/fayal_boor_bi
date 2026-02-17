class Payment {
  final int? id;
  final int debtId;
  final double amount;
  final DateTime paymentDate;
  final String? method;
  final String? reference;
  final String? notes;
  final int? userId;

  Payment({
    this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    this.method,
    this.reference,
    this.notes,
    this.userId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] != null
          ? int.parse(json['id'].toString())
          : null,

      debtId: int.parse(json['debt_id'].toString()),
      amount: double.parse(json['amount'].toString()),
      paymentDate: DateTime.parse(json['payment_date'].toString()),

      method: json['method']?.toString(),
      reference: json['reference']?.toString(),
      notes: json['notes']?.toString(),
      userId: json['user_id'] != null
          ? int.parse(json['user_id'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // ⚠ on n’envoie pas id si null
      'debt_id': debtId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'method': method,
      'reference': reference,
      'notes': notes,
      'user_id': userId,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
