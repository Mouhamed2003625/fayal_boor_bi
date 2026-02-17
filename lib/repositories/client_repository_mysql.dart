import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/client_model.dart';
import '../services/api_config.dart';
import 'client_repository.dart';

class ClientRepositoryMySql implements ClientRepository {
  final http.Client _client;

  ClientRepositoryMySql({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<Client>> getClients({String? search}) async {
    final uri = Uri.parse(ApiConfig.listClientUrl()).replace(
      queryParameters: search != null && search.isNotEmpty
          ? {'search': search}
          : null,
    );

    final response = await _client.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode != 200) {
      throw Exception('Erreur chargement clients: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final List<dynamic> data = body['data'] ?? [];

    return data.map((e) => Client.fromJson(e)).toList();
  }

  @override
  Future<Client> getClientById(int id) async {
    final uri = Uri.parse(ApiConfig.listClientByIdUrl(id));
    final response = await _client.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode != 200) {
      throw Exception('Erreur chargement client: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final jsonData = body['data'];
    return Client.fromJson(jsonData);
  }

  @override
  Future<Client> createClient(Client client) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.createClientUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur création client: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    return Client.fromJson(body['data']);
  }

  @override
  Future<Client> updateClient(Client client) async {
    final response = await _client.put(
      Uri.parse(ApiConfig.updateClientUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur mise à jour client: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    return Client.fromJson(body['data']);
  }

  @override
  Future<void> deleteClient(int id) async {
    final response = await _client.delete(
      Uri.parse(ApiConfig.deleteClientUrl(id)),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur suppression client: ${response.statusCode}');
    }
  }
}
