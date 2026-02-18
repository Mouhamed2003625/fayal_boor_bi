import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/payment_model.dart';
import '../notifiers/payment_state.dart';
import '../repositories/payment_repository.dart';
import 'payment_ripository_provider.dart';
import 'client_provider.dart';

final paymentProvider =
StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repository: repo, ref: ref);
});

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository repository;
  final Ref ref;

  PaymentNotifier({required this.repository, required this.ref})
      : super(PaymentState());

  Future<void> loadAllPayments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payments = await repository.getAllPayments();
      state = state.copyWith(payments: payments, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addPayment(Payment payment) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newPayment = await repository.createPayment(payment);
      state = state.copyWith(payments: [...state.payments, newPayment], isLoading: false);
      await ref.read(clientProvider.notifier).loadClients();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updatePayment(Payment payment) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await repository.updatePayment(payment);
      final updatedList = state.payments.map((p) => p.id == updated.id ? updated : p).toList();
      state = state.copyWith(payments: updatedList, isLoading: false);
      await ref.read(clientProvider.notifier).loadClients();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deletePayment(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.deletePayment(id);
      state = state.copyWith(
          payments: state.payments.where((p) => p.id != id).toList(), isLoading: false);
      await ref.read(clientProvider.notifier).loadClients();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
