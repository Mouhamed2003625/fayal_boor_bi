import '../models/client_model.dart';

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
