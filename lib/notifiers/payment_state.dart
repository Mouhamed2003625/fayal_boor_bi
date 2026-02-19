import '../models/payment_model.dart';

class PaymentState {
  final bool isLoading;
  final String? error;
  final List<Payment> payments;

  PaymentState({
    this.isLoading = false,
    this.error,
    this.payments = const [],
  });

  PaymentState copyWith({
    bool? isLoading,
    String? error,
    List<Payment>? payments,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      payments: payments ?? this.payments,
    );
  }
}
