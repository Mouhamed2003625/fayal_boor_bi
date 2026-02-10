import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:weer_bi_dena/notifiers/client_state.dart';

import '../models/client_model.dart';
import '../repositories/client_repository.dart';
import '../repositories/client_repository_mysql.dart';


// ============================================================================
// Provider du repository (abstraction propre)
// ============================================================================
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryMySql();
});


// ============================================================================
// Provider Async : liste des clients
// ============================================================================
final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.getClients();
});


// ============================================================================
// StateNotifier : gestion d’un client spécifique
// ============================================================================
class ClientNotifier extends StateNotifier<ClientState> {
  final ClientRepository repository;

  ClientNotifier({required this.repository}) : super(ClientState());

  // chargement de tous les clients
  Future<void> loadClients({String? search}) async{
    try {
      state = state.copyWith(isLoading: true, error: null);
      final clients= await repository.getClients(search: search);
      state =state.copyWith(clients: clients, isLoading: false);
    } catch(e){
      state.copyWith(isLoading: false, error: e.toString());
    }
  }


  // Creer d'un nouveau client
  Future<void> addClient(Client client) async {
    try{
      final newClient = await repository.createClient(client);
      state = state.copyWith(clients: [...state.clients, newClient]);
    }catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Mise a jour d'un client
  Future<void> updateClient(Client client) async {
    try{
      final updated = await repository.updateClient(client);
      final updatedList = state.clients.map((c) => c.id == updated.id ? updated: c).toList();
      state = state.copyWith(clients: updatedList);
    }catch (e) {
      state = state.copyWith(error:  e.toString());
    }
  }

  //Suppression d'un client
  Future<void> deleteClient(String id) async{
    try {
      await repository.deleteClient(id);
      final updatedList = state.clients.where((c) => c.id !=id).toList();
      state = state.copyWith(clients: updatedList);
    }catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}



// ============================================================================
// Provider du ClientNotifier
// ============================================================================
final clientProvider =
StateNotifierProvider<ClientNotifier, ClientState>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return ClientNotifier(repository: repository);
});
