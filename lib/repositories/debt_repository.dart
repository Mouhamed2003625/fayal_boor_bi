// ============================================================================
//  DEBT REPOSITORY (PHP/MySQL)
//  Ce fichier contient toutes les fonctions permettant d’interagir avec l’API
//  backend : ajout de dette, récupération de la liste, suppression.
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/debt_model.dart';
import '../services/api_config.dart';

/// ============================================================================
///  CLASSE PRINCIPALE DU REPOSITORY
/// ============================================================================
class DebtRepositoryMySql {
  // --------------------------------------------------------------------------
  // 1) AJOUT D’UNE DETTE (POST multipart)
  // --------------------------------------------------------------------------
  Future<void> addDebt({
    required String clientName,
    required double amount,
    String? description,
    String? userId,
  }) async {
    final uri = Uri.parse(ApiConfig.createDebtUrl());

    final req = http.MultipartRequest('POST', uri)
      ..fields['client_name'] = clientName.trim()
      ..fields['amount'] = amount.toString()
      ..fields['description'] = description?.trim() ?? '';

    if (userId != null && userId.isNotEmpty) {
      req.fields['user_id'] = userId;
    }

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode != 200) {
      throw Exception('API error ${res.statusCode}: $body');
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
          final normalizedMap = Map<String, dynamic>.from(e);
          return Debt.fromJson(normalizedMap);
        }
        if (e is String) {
          final decoded = jsonDecode(e);
          if (decoded is Map) {
            final normalizedMap = Map<String, dynamic>.from(decoded);
            return Debt.fromJson(normalizedMap);
          } else {
            throw Exception('Élément JSON décodé invalide : $e');
          }
        }
        throw Exception('Format inattendu dans data: ${e.runtimeType} → $e');
      }).toList();
    }

    throw Exception('Réponse invalide: ${res.body}');
  }

  // --------------------------------------------------------------------------
  // 3) SUPPRESSION D’UNE DETTE (POST)
  // --------------------------------------------------------------------------
  Future<void> deleteDebt(int id) async {
    final uri = Uri.parse(ApiConfig.deleteDebtUrl());

    final res = await http.post(uri, body: {'id': '$id'});

    if (res.statusCode != 200) {
      throw Exception('API ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> j =
    jsonDecode(res.body) as Map<String, dynamic>;

    if (j['ok'] != true) {
      throw Exception('Suppression échouée: ${res.body}');
    }
  }
}

// ============================================================================
//  PROVIDER RIVERPOD
// ============================================================================
final debtRepositoryMySqlProvider =
Provider<DebtRepositoryMySql>((ref) => DebtRepositoryMySql());
