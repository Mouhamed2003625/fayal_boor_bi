import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/debt_model.dart';
import '../repositories/debt_repository.dart';
import 'debt_repository_provider.dart';

/// État du provider
class DebtState {
  final List<Debt> debts;
  final bool isLoading;
  final String? error;

  const DebtState({
    this.debts = const [],
    this.isLoading = false,
    this.error,
  });

  DebtState copyWith({
    List<Debt>? debts,
    bool? isLoading,
    String? error,
  }) {
    return DebtState(
      debts: debts ?? this.debts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// StateNotifier pour gérer les dettes
class DebtNotifier extends StateNotifier<DebtState> {
  final DebtRepository _repository;

  DebtNotifier({required DebtRepository repository})
      : _repository = repository,
        super(const DebtState());

  /// Charger les dettes (optionnellement par client)
  Future<void> loadDebts({int? clientId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final debts = await _repository.fetchDebts(clientId: clientId);
      state = state.copyWith(debts: debts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Ajouter une dette
  Future<void> addDebt({
    required int clientId,
    required String product,
    required int quantity,
    required double amount,
    required DateTime dueDate, // DateTime ici
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newDebt = Debt(
        id: 0,
        clientId: clientId,
        product: product,
        quantity: quantity,
        amount: amount,
        dueDate: dueDate, // Laisse DateTime, le repository convertira en String
      );

      final addedDebt = await _repository.addDebt(newDebt);
      state = state.copyWith(
        debts: [...state.debts, addedDebt],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }


  /// Mettre à jour une dette
  Future<void> updateDebt(Debt debt) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedDebt = await _repository.updateDebt(debt);
      final index = state.debts.indexWhere((d) => d.id == updatedDebt.id);
      final updatedList = [...state.debts];
      if (index >= 0) updatedList[index] = updatedDebt;
      state = state.copyWith(debts: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Supprimer une dette
  Future<void> deleteDebt(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteDebt(id);
      final updatedList = state.debts.where((d) => d.id != id).toList();
      state = state.copyWith(debts: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Marquer une dette comme payée
  Future<void> markDebtAsPaid(int debtId, DateTime paymentDate) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedDebt =
      await _repository.markDebtAsPaid(debtId: debtId, paymentDate: paymentDate);
      final index = state.debts.indexWhere((d) => d.id == debtId);
      final updatedList = [...state.debts];
      if (index >= 0) updatedList[index] = updatedDebt;
      state = state.copyWith(debts: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Provider global
final debtProvider = StateNotifierProvider<DebtNotifier, DebtState>(
      (ref) {
    final repo = ref.watch(debtRepositoryProvider);
    return DebtNotifier(repository: repo);
  },
);
