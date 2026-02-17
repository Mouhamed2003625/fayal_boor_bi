import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/client_model.dart';
import '../../providers/client_provider.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Charger les clients au démarrage
    Future.microtask(() => ref.read(clientProvider.notifier).loadClients());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientProvider);

    final clients = state.clients
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.dashboard, color: Color(0xFF3B82F6)),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text(
          "Liste des Clients",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF3B82F6)),
            onPressed: () => context.go('/addclient'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            onPressed: () => ref.read(clientProvider.notifier).loadClients(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un client...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() {
                _searchQuery = value;
              }),
            ),
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? _buildErrorState(state.error!)
          : clients.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: () async =>
            ref.read(clientProvider.notifier).loadClients(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clients.length,
          itemBuilder: (context, index) =>
              _buildClientCard(clients[index]),
        ),
      ),
    );
  }

  Widget _buildClientCard(Client client) {
    final totalAmount =
    client.debts.fold<double>(0, (sum, d) => sum + d.amount);
    final totalPaid =
    client.debts.fold<double>(0, (sum, d) => sum + d.paidAmount);
    final balance = totalAmount - totalPaid;

    Color avatarColor;
    if (balance == 0) {
      avatarColor = const Color(0xFF16A34A);
    } else if (balance > 0) {
      avatarColor = const Color(0xFFDC2626);
    } else {
      avatarColor = const Color(0xFF3B82F6);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(client.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.phone, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            if (client.address?.isNotEmpty == true)
              Text(client.address!, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            Text(
              balance == 0
                  ? "Soldé"
                  : "Solde: ${balance.abs().toStringAsFixed(0)} FCFA ${balance > 0 ? 'dû' : 'crédit'}",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: balance > 0
                      ? Colors.red
                      : balance == 0
                      ? Colors.green
                      : Colors.blue),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF3B82F6)),
        onTap: () => context.goNamed('infosclients', extra: client),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 20),
        const Text("Aucun client",
            style: TextStyle(fontSize: 18, color: Color(0xFF94A3B8))),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/addclient'),
          icon: const Icon(Icons.add),
          label: const Text("Ajouter un client"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ),
  );

  Widget _buildErrorState(String error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
        const SizedBox(height: 16),
        const Text("Erreur de chargement",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red)),
        const SizedBox(height: 8),
        Text(error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => ref.read(clientProvider.notifier).loadClients(),
          icon: const Icon(Icons.refresh),
          label: const Text("Réessayer"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
          ),
        ),
      ]),
    ),
  );
}
