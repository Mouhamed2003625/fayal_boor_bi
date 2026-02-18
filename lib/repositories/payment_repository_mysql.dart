import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/payment_model.dart';
import '../services/api_config.dart';
import 'payment_repository.dart';

class PaymentRepositoryMySql implements PaymentRepository {
  final http.Client _client;

  PaymentRepositoryMySql({http.Client? client})
      : _client = client ?? http.Client();

  /// ================= LIST by debt =================
  @override
  Future<List<Payment>> getPaymentsByDebt(int debtId) async {
    final uri = Uri.parse(ApiConfig.listPaymentUrl(debtId));

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur chargement paiements: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);

    if (body['ok'] != true) {
      throw Exception(body['message'] ?? 'Erreur serveur');
    }

    final List<dynamic> data = body['data'] ?? [];

    return data.map((json) => Payment.fromJson(json)).toList();
  }

  /// ================= LIST ALL =================
  @override
  Future<List<Payment>> getAllPayments() async {
    final uri = Uri.parse(ApiConfig.listAllPaymentsUrl()); // 🔹 à créer dans ApiConfig

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur chargement tous les paiements: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);

    if (body['ok'] != true) {
      throw Exception(body['message'] ?? 'Erreur serveur');
    }

    final List<dynamic> data = body['data'] ?? [];

    return data.map((json) => Payment.fromJson(json)).toList();
  }

  /// ================= CREATE =================
  @override
  Future<Payment> createPayment(Payment payment) async {
    final uri = Uri.parse(ApiConfig.createPaymentUrl());

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payment.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final body = jsonDecode(response.body);

    if (body['ok'] != true) {
      throw Exception(body['message'] ?? 'Création échouée');
    }

    return Payment.fromJson(body['data']);
  }

  /// ================= UPDATE =================
  @override
  Future<Payment> updatePayment(Payment payment) async {
    final uri = Uri.parse(ApiConfig.updatePaymentUrl());

    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payment.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final body = jsonDecode(response.body);

    if (body['ok'] != true) {
      throw Exception(body['message'] ?? 'Mise à jour échouée');
    }

    return Payment.fromJson(body['data']);
  }

  /// ================= DELETE =================
  @override
  Future<void> deletePayment(int id) async {
    final uri = Uri.parse(ApiConfig.deletePaymentUrl(id));

    final response = await _client.delete(uri);

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final body = jsonDecode(response.body);

    if (body['ok'] != true) {
      throw Exception(body['message'] ?? 'Suppression échouée');
    }
  }
}
