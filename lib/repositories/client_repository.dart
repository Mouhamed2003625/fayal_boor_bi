import '../models/client_model.dart';

/// ============================================================================
/// Interface (contrat) du repository Client
/// ============================================================================
abstract class ClientRepository {
  Future<List<Client>> getClients({String? search});

  Future<Client> getClientById(int id);

  Future<Client> createClient(Client client);

  Future<Client> updateClient(Client client);

  Future<void> deleteClient(int id);
}
