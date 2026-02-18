import 'package:weer_bi_dena/models/payment_model.dart';
import 'client_model.dart';

class Debt {
  final int id;
  final int clientId;
  final String product;
  final int quantity;
  final double amount; // montant total de la dette
  final DateTime dueDate;
  final List<Payment> payments;
  final Client? client;

  Debt({
    required this.id,
    required this.clientId,
    required this.product,
    required this.quantity,
    required this.amount,
    required this.dueDate,
    this.payments = const [],
    this.client,
  });

  /// Montant déjà payé
  double get paidAmount => payments.fold(0, (sum, p) => sum + p.amount);

  /// Vérifie si la dette est entièrement payée
  bool get isPaid => paidAmount == amount || paidAmount >= amount ;

  /// Création depuis JSON (API)
  factory Debt.fromJson(Map<String, dynamic> json) {
    // On prend le montant soit dans 'amount' soit dans 'debtAmount' si l'API ne renvoie pas amount
    double parseAmount(Map<String, dynamic> data) {
      if (data['amount'] != null) {
        return double.tryParse(data['amount'].toString()) ?? 0.0;
      } else if (data['debtAmount'] != null) {
        return double.tryParse(data['debtAmount'].toString()) ?? 0.0;
      } else {
        return 0.0;
      }
    }

    return Debt(
      id: int.parse(json['id'].toString()),
      clientId: int.parse(json['client_id'].toString()),
      product: json['product'] ?? 'Produit inconnu',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      amount: parseAmount(json),
      dueDate: DateTime.tryParse(json['due_date']?.toString() ?? '') ??
          DateTime.now(),
      payments: json['payments'] != null
          ? List<Payment>.from(
          json['payments'].map((p) => Payment.fromJson(p)))
          : [],
      client:
      json['client'] != null ? Client.fromJson(json['client']) : null,
    );
  }

  /// Conversion vers JSON pour API
  Map<String, dynamic> toJson() => {
    'id': id,
    'client_id': clientId,
    'product': product,
    'quantity': quantity,
    'amount': amount,
    'due_date': dueDate.toIso8601String(),
    'payments': payments.map((p) => p.toJson()).toList(),
    'client': client?.toJson(),
  };
}
