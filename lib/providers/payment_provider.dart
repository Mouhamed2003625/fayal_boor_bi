import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/payment_model.dart';
import '../notifiers/payment_state.dart';
import '../repositories/payment_repository.dart';
import '../repositories/payment_repository_mysql.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryMySql();
});



/// Liste des paiements par dette
class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository repository;

  PaymentNotifier({required this.repository}) : super(PaymentState());

  /// Charger les paiements d’une dette
  Future<void> loadPayments(int debtId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final payments = await repository.getPaymentsByDebt(debtId);
      state = state.copyWith(payments: payments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Créer un paiement
  Future<void> addPayment(Payment payment) async {
    try {
      final newPayment = await repository.createPayment(payment);
      state = state.copyWith(payments: [...state.payments, newPayment]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mettre à jour un paiement
  Future<void> updatePayment(Payment payment) async {
    try {
      final updated = await repository.updatePayment(payment);
      final updatedList = state.payments.map((p) => p.id == updated.id ? updated : p).toList();
      state = state.copyWith(payments: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Supprimer un paiement
  Future<void> deletePayment(int id) async {
    try {
      await repository.deletePayment(id);
      final updatedList = state.payments.where((p) => p.id != id).toList();
      state = state.copyWith(payments: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Provider pour un paiement spécifique

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repository: repository);
});