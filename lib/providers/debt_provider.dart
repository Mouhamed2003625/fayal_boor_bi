import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/debt_model.dart';
import '../notifiers/debt_state.dart';
import '../repositories/debt_repository.dart';
import '../repositories/debt_repository_mysql.dart';


// ============================================================================
// Provider du repository (abstraction)
// ============================================================================
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepositoryMysql();
});


// ============================================================================
// StateNotifier pour gérer les dettes
// ============================================================================
class DebtNotifier extends StateNotifier<DebtState> {
  final DebtRepository repository;

  DebtNotifier({required this.repository}) : super(DebtState());

  Future<void> loadDebts({String? userId, String? clientId}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final debts = await repository.fetchDebts(userId: userId, clientId: clientId);
      state = state.copyWith(debts: debts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addDebt(Debt debt) async {
    try {
      final newDebt = await repository.addDebt(
        clientId: debt.clientId,
        amount: debt.amount,
        description: debt.description,
        dueDate: debt.dueDate,
        paymentMethod: debt.paymentMethod,
        paymentReference: debt.paymentReference,
        notes: debt.notes,
        userId: debt.userId,
      );
      state = state.copyWith(debts: [...state.debts, newDebt]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateDebt(Debt debt) async {
    try {
      final updatedDebt = await repository.updateDebt(debt);
      state = state.copyWith(
        debts: [
          for (final d in state.debts)
            if (d.id == updatedDebt.id) updatedDebt else d
        ],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteDebt(int id) async {
    try {
      await repository.deleteDebt(id);
      state = state.copyWith(debts: state.debts.where((d) => d.id != id).toList());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markDebtAsPaid({required int debtId, required DateTime paymentDate}) async {
    try {
      final updatedDebt = await repository.markDebtAsPaid(debtId: debtId, paymentDate: paymentDate);
      state = state.copyWith(
        debts: [
          for (final d in state.debts)
            if (d.id == updatedDebt.id) updatedDebt else d
        ],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}


// ============================================================================
// Provider du DebtNotifier
// ============================================================================

final debtProvider = StateNotifierProvider<DebtNotifier, DebtState>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return DebtNotifier(repository: repository);
});
