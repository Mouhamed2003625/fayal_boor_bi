import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/debt_model.dart';
import 'api_config.dart';

class DebtRepositoryMySql {
  // --------------------------------------------------------------------------
  // 1) AJOUT D’UNE DETTE (POST en JSON pour Flutter Web)
  // --------------------------------------------------------------------------
  Future<void> addDebt({
    required String clientName,
    required String phoneNumber,
    required double amount,
    required String description,
    required bool isPaid,
    required DateTime dates,
    String? userId, // Optionnel
  }) async {
    final uri = Uri.parse(ApiConfig.createDebtUrl());

    // Préparer le body en JSON
    final Map<String, dynamic> body = {
      'clientName': clientName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'amount': amount,
      'description': description.trim(),
      'dates': dates.toIso8601String(),
      'isPaid': isPaid,
    };

    // Ajouter userId seulement s'il est fourni
    if (userId != null && userId.isNotEmpty) {
      body['userId'] = userId;
    }

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map && decoded['ok'] != true) {
      throw Exception('Erreur API: ${decoded['message'] ?? res.body}');
    }
  }

  // --------------------------------------------------------------------------
  // 2) RÉCUPÉRATION DE LA LISTE DES DETTES (GET)
  // --------------------------------------------------------------------------
  Future<List<Debt>> fetchDebts() async {
    final uri = Uri.parse(ApiConfig.listDebtUrl());
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('API ${res.statusCode}: ${res.body}');
    }

    final jsonData = jsonDecode(res.body);

    if (jsonData is Map && jsonData['ok'] == true && jsonData['data'] is List) {
      final List data = jsonData['data'];
      return data.map<Debt>((e) {
        if (e is Map) {
          return Debt.fromJson(Map<String, dynamic>.from(e));
        }
        throw Exception('Format inattendu dans data: ${e.runtimeType} → contenu: $e');
      }).toList();
    }

    throw Exception('Réponse invalide: ${res.body}');
  }

  // --------------------------------------------------------------------------
  // 3) SUPPRESSION D’UNE DETTE (POST)
  // --------------------------------------------------------------------------
  Future<void> deleteDebt(int id) async {
    final uri = Uri.parse(ApiConfig.deleteDebtUrl());
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (res.statusCode != 200) {
      throw Exception('API ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> j = jsonDecode(res.body);
    if (j['ok'] != true) {
      throw Exception('Suppression échouée: ${res.body}');
    }
  }
}


// --------------------------------------------------------------------------
// 4) MODIFICATION D’UNE DETTE (POST vers backend)
// --------------------------------------------------------------------------
Future<void> updateDebt({
  required String clientName,
  required String phoneNumber,
  required double amount,
  required String description,
  required bool isPaid,
  required DateTime dates,
  String? userId,
}) async {
  final uri = Uri.parse(ApiConfig.updateDebtUrl()); // Crée cette URL dans ApiConfig

  final Map<String, dynamic> body = {
    'clientName': clientName.trim(),
    'phoneNumber': phoneNumber.trim(),
    'amount': amount,
    'description': description.trim(),
    'dates': dates.toIso8601String(),
    'isPaid': isPaid ? 1 : 0, // ou true selon ton backend
  };

  if (userId != null && userId.isNotEmpty) {
    body['userId'] = userId;
  }

  final res = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (res.statusCode != 200) {
    throw Exception('API error ${res.statusCode}: ${res.body}');
  }

  final decoded = jsonDecode(res.body);
  if (decoded is Map && decoded['ok'] != true) {
    throw Exception('Erreur API update: ${decoded['message'] ?? res.body}');
  }
}



// ============================================================================
//  PROVIDER RIVERPOD
// ============================================================================
final debtRepositoryMySqlProvider =
Provider<DebtRepositoryMySql>((ref) => DebtRepositoryMySql());
