class Payment {
  final int? id;
  final int debtId;
  final double amount;
  final DateTime paymentDate;
  final String? method;
  final String? reference;
  final String? notes;
  final int? userId;

  // 🔹 Champs pour affichage
  final String? clientName;
  final String? product;

  Payment({
    this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    this.method,
    this.reference,
    this.notes,
    this.userId,
    this.clientName,
    this.product,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      debtId: int.parse(json['debt_id'].toString()),
      amount: double.parse(json['amount'].toString()),
      paymentDate: DateTime.parse(json['payment_date'].toString()),
      method: json['method']?.toString(),
      reference: json['reference']?.toString(),
      notes: json['notes']?.toString(),
      userId: json['user_id'] != null ? int.parse(json['user_id'].toString()) : null,
      clientName: json['client_name']?.toString(),
      product: json['product']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'debt_id': debtId,
    'amount': amount,
    'payment_date': paymentDate.toIso8601String(),
    'method': method,
    'reference': reference,
    'notes': notes,
    'user_id': userId,
    'client_name': clientName,
    'product': product,
  };
}
