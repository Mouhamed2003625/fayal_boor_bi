import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/debt_model.dart';
import '../services/api_config.dart';
import 'debt_repository.dart';

class DebtRepositoryMysql implements DebtRepository {
  final http.Client _client;

  DebtRepositoryMysql({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<Debt>> fetchDebts({int? clientId}) async {
    final uri = Uri.parse(ApiConfig.listDebtUrl()).replace(
      queryParameters:
      clientId != null ? {'client_id': clientId.toString()} : null,
    );

    final res =
    await _client.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode != 200) {
      throw Exception(
          'Erreur chargement dettes (${res.statusCode}) : ${res.body}');
    }

    final body = jsonDecode(res.body);
    final List data = body['data'] ?? [];

    return data.map((e) => Debt.fromJson(e)).toList();
  }

  Future<Debt> addDebt(Debt debt) async {
    // Conversion DateTime -> String YYYY-MM-DD
    final dueDateStr =
        '${debt.dueDate.year}-${debt.dueDate.month.toString().padLeft(2, '0')}-${debt.dueDate.day.toString().padLeft(2, '0')}';

    final response = await _client.post(
      Uri.parse(ApiConfig.createDebtUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'clientId': debt.clientId,
        'product': debt.product,
        'quantity': debt.quantity,
        'amount': debt.amount,
        'dueDate': dueDateStr,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['ok'] != true) {
      throw Exception(data['message'] ?? 'Erreur lors de la création de la dette');
    }

    return Debt.fromJson(data['data']);
  }

  @override
  Future<Debt> updateDebt(Debt debt) async {
    // Convertir la date au format MySQL
    final dueDateStr = debt.dueDate != null
        ? '${debt.dueDate!.year.toString().padLeft(4,'0')}-'
        '${debt.dueDate!.month.toString().padLeft(2,'0')}-'
        '${debt.dueDate!.day.toString().padLeft(2,'0')}'
        : null;

    final Map<String, dynamic> body = {
      'id': debt.id,
      'product': debt.product,
      'quantity': debt.quantity,
      'amount': debt.amount,
      'dueDate': dueDateStr, // envoyé comme string
    };

    final res = await _client.put(
      Uri.parse(ApiConfig.updateDebtUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception(
          'Erreur mise à jour dette (${res.statusCode}) : ${res.body}');
    }

    final bodyData = jsonDecode(res.body);
    final jsonData = bodyData['data'];

    return Debt.fromJson(jsonData);
  }


  @override
  Future<void> deleteDebt(int id) async {
    final res =
    await _client.delete(Uri.parse(ApiConfig.deleteDebtUrl(id)));

    if (res.statusCode != 200) {
      throw Exception(
          'Erreur suppression dette (${res.statusCode}) : ${res.body}');
    }
  }

  @override
  Future<Debt> markDebtAsPaid({
    required int debtId,
    required DateTime paymentDate,
  }) async {
    final res = await _client.post(
      Uri.parse(ApiConfig.markDebtAsPaidUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'debt_id': debtId,
        'payment_date': paymentDate.toIso8601String(),
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(
          'Erreur paiement dette (${res.statusCode}) : ${res.body}');
    }

    final body = jsonDecode(res.body);
    final jsonData = body['data'];

    return Debt.fromJson(jsonData);
  }
}
