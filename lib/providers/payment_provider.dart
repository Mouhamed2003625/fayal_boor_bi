import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:weer_bi_dena/providers/payment_ripository_provider.dart';

import '../models/payment_model.dart';
import '../notifiers/payment_state.dart';
import '../repositories/payment_repository.dart';

final paymentProvider =
StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repository: repo);
});

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository repository;

  PaymentNotifier({required this.repository}) : super(PaymentState());

  /// ================= LOAD =================
  Future<void> loadPayments(int debtId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final payments = await repository.getPaymentsByDebt(debtId);

      state = state.copyWith(
        payments: payments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// ================= ADD =================
  Future<void> addPayment(Payment payment) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newPayment = await repository.createPayment(payment);

      state = state.copyWith(
        payments: [...state.payments, newPayment],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// ================= UPDATE =================
  Future<void> updatePayment(Payment payment) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updated = await repository.updatePayment(payment);

      final updatedList = state.payments.map((p) {
        return p.id == updated.id ? updated : p;
      }).toList();

      state = state.copyWith(
        payments: updatedList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// ================= DELETE =================
  Future<void> deletePayment(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await repository.deletePayment(id);

      state = state.copyWith(
        payments: state.payments.where((p) => p.id != id).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}
