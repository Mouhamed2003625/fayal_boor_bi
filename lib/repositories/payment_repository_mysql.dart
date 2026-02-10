import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weer_bi_dena/repositories/payment_repository.dart';

import '../models/payment_model.dart';
import '../services/api_config.dart';

class PaymentRepositoryMySql implements PaymentRepository{

  /// Récupérer tous les paiements d'une dette

  @override
  Future<List<Payment>> getPaymentsByDebt(int debtId) async {
    final uri = Uri.parse(ApiConfig.listPaymentUrl(debtId));
    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Erreur API ${response.statusCode}: ${response.body}');
    }

    final List<dynamic> data =
        json.decode(response.body)['data'] ?? json.decode(response.body);

    return data.map((json) => Payment.fromJson(json)).toList();
  }

  /// Créer un paiement
  @override
  Future<Payment> createPayment(Payment payment) async {
    final uri = Uri.parse(ApiConfig.createPaymentUrl());
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payment.toMap()));

    if (response.statusCode != 200) {
      throw Exception('Erreur API ${response.statusCode}: ${response.body}');
    }

    final jsonData =
        json.decode(response.body)['data'] ?? json.decode(response.body);

    return Payment.fromJson(jsonData);
  }

  /// Mettre à jour un paiement
  @override
  Future<Payment> updatePayment(Payment payment) async {
    final uri = Uri.parse(ApiConfig.updatePaymentUrl());
    final response = await http.put(uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payment.toMap()));

    if (response.statusCode != 200) {
      throw Exception('Erreur API ${response.statusCode}: ${response.body}');
    }

    final jsonData =
        json.decode(response.body)['data'] ?? json.decode(response.body);

    return Payment.fromJson(jsonData);
  }

  /// Supprimer un paiement
  @override
  Future<void> deletePayment(int id) async {
    final uri = Uri.parse(ApiConfig.deletePaymentUrl());
    final response = await http.delete(uri, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    }, body: json.encode({'id': id}));

    if (response.statusCode != 200) {
      throw Exception('Erreur API ${response.statusCode}: ${response.body}');
    }
  }
}
