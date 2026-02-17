import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/client_model.dart';
import '../repositories/client_repository.dart';
import 'client_repository_provider.dart';

/// État du provider
class ClientState {
  final List<Client> clients;
  final bool isLoading;
  final String? error;

  ClientState({
    this.clients = const [],
    this.isLoading = false,
    this.error,
  });

  ClientState copyWith({
    List<Client>? clients,
    bool? isLoading,
    String? error,
  }) {
    return ClientState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// StateNotifier pour gérer les clients
class ClientNotifier extends StateNotifier<ClientState> {
  final ClientRepository _repository;

  ClientNotifier({required ClientRepository repository})
      : _repository = repository,
        super(ClientState());

  /// Charger tous les clients
  Future<void> loadClients({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final clients = await _repository.getClients(search: search);
      state = state.copyWith(clients: clients, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Créer un client
  Future<void> createClient(Client client) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newClient = await _repository.createClient(client);
      final updatedList = [...state.clients, newClient];
      state = state.copyWith(clients: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Mettre à jour un client
  Future<void> updateClient(Client client) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedClient = await _repository.updateClient(client);
      final index = state.clients.indexWhere((c) => c.id == updatedClient.id);
      final updatedList = [...state.clients];
      if (index >= 0) updatedList[index] = updatedClient;
      state = state.copyWith(clients: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Supprimer un client
  Future<void> deleteClient(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteClient(id);
      final updatedList = state.clients.where((c) => c.id != id).toList();
      state = state.copyWith(clients: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Filtrer les clients localement
  List<Client> searchClients(String query) {
    if (query.isEmpty) return state.clients;
    return state.clients
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

final clientProvider =
StateNotifierProvider<ClientNotifier, ClientState>((ref) {
  final repository = ref.read(clientRepositoryProvider);
  return ClientNotifier(repository: repository);
});

