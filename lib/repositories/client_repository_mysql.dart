import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/client_model.dart';
import '../services/api_config.dart';
import 'client_repository.dart';

class ClientRepositoryMySql implements ClientRepository {
  // http.client: ici client represente l'pbjet capable de gerer le cycle de vie d'une requete.
  // comme la configuration des headers, les redirections, et le pool de connexions.
  // c'est a dire il permet d'envoyer des requetes http et de recevoir des reponses http.
  final http.Client _httpClient;

  ClientRepositoryMySql({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // --------------------------------------------------------------------------
  // Récupérer tous les clients
  // --------------------------------------------------------------------------
  @override
  Future<List<Client>> getClients({String? search}) async {
    final uri = Uri.parse(ApiConfig.listClientUrl()).replace(
      queryParameters: {
        if (search != null || search!.isNotEmpty) 'search' : search,
      },
    );

    final response = await _httpClient.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur chargement clients: ${response.statusCode} Reason : ${response.reasonPhrase}');
    }

    final body = jsonDecode(response.body);
    final List data = body['data'] ?? [];
    return data.map((e) => Client.fromJson(e)).toList();
  }

  // --------------------------------------------------------------------------
  // Récupérer un client par ID
  // --------------------------------------------------------------------------
  @override
  Future<Client> getClientById(String id) async {
    final uri = Uri.parse(ApiConfig.listClientByIdUrl(id));

    final response = await _httpClient.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur chargement client: ${response.statusCode} Reason : ${response.reasonPhrase}');
    }

    final jsonData = jsonDecode(response.body)['data'];
    return Client.fromJson(jsonData);
  }

  // --------------------------------------------------------------------------
  // Créer un client
  // --------------------------------------------------------------------------
  @override
  Future<Client> createClient(Client client) async {
    final response = await _httpClient.post(
      Uri.parse(ApiConfig.createClientUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur création client: ${response.statusCode} Reason: ${response.reasonPhrase}');
    }

    final jsonData = jsonDecode(response.body)['data'];
    return Client.fromJson(jsonData);
  }

  // --------------------------------------------------------------------------
  // Mettre à jour un client
  // --------------------------------------------------------------------------
  @override
  Future<Client> updateClient(Client client) async {
    final response = await _httpClient.post(
      Uri.parse(ApiConfig.updateClientUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur mise à jour client');
    }

    final jsonData = jsonDecode(response.body)['data'];
    return Client.fromJson(jsonData);
  }

  // --------------------------------------------------------------------------
  // Supprimer un client
  // --------------------------------------------------------------------------
  @override
  Future<void> deleteClient(String id) async {
    final response = await _httpClient.post(
      Uri.parse(ApiConfig.deleteClientUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur suppression client');
    }
  }
}
