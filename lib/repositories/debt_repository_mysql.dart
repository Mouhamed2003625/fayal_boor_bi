import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/debt_model.dart';
import '../services/api_config.dart';
import 'debt_repository.dart';

class DebtRepositoryMysql implements DebtRepository {
  // --------------------------------------------------------------------------
  // Récupérer toutes les dettes (optionnel : filtrer par userId ou clientId)
  // --------------------------------------------------------------------------
  @override
  Future<List<Debt>> fetchDebts({String? userId, String? clientId}) async {
    final uri = Uri.parse(ApiConfig.listDebtUrl());

    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (res.statusCode != 200) {
      throw Exception('Erreur chargement dettes: ${res.statusCode}');
    }

    final body = jsonDecode(res.body);
    final List data = body['data'] ?? [];
    return data.map((e) => Debt.fromJson(e)).toList();
  }

  // --------------------------------------------------------------------------
  // Créer une dette
  // --------------------------------------------------------------------------
  @override
  Future<Debt> addDebt({
    required String clientId,
    required double amount,
    required String description,
    DateTime? dueDate,
    String? paymentMethod,
    String? paymentReference,
    String? notes,
    String? userId,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConfig.createDebtUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'clientId': clientId,
        'amount': amount,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'paymentMethod': paymentMethod,
        'paymentReference': paymentReference,
        'notes': notes,
        'userId': userId,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Erreur création dette: ${res.statusCode}');
    }

    final jsonData = jsonDecode(res.body)['data'];
    return Debt.fromJson(jsonData);
  }

  // --------------------------------------------------------------------------
  // Mettre à jour une dette
  // --------------------------------------------------------------------------
  @override
  Future<Debt> updateDebt(Debt debt) async {
    final res = await http.put(
      Uri.parse(ApiConfig.updateDebtUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(debt.toMap()),
    );

    if (res.statusCode != 200) {
      throw Exception('Erreur mise à jour dette: ${res.statusCode}');
    }

    final jsonData = jsonDecode(res.body)['data'];
    return Debt.fromJson(jsonData);
  }

  // --------------------------------------------------------------------------
  // Supprimer une dette
  // --------------------------------------------------------------------------
  @override
  Future<void> deleteDebt(int id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.deleteDebtUrl(id)),
    );

    if (res.statusCode != 200) {
      throw Exception('Erreur suppression dette: ${res.statusCode}');
    }
  }

  // --------------------------------------------------------------------------
  // Marquer une dette comme payée
  // --------------------------------------------------------------------------
  @override
  Future<Debt> markDebtAsPaid({
    required int debtId,
    required DateTime paymentDate,
    String? paymentMethod,
    String? paymentReference,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConfig.markDebtAsPaidUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': debtId,
        'paymentDate': paymentDate.toIso8601String(),
        'paymentMethod': paymentMethod,
        'paymentReference': paymentReference,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Erreur paiement dette: ${res.statusCode}');
    }

    final jsonData = jsonDecode(res.body)['data'];
    return Debt.fromJson(jsonData);
  }
}
