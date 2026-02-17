import '../models/payment_model.dart';

class PaymentState {
  final List<Payment> payments;
  final bool isLoading;
  final String? error;

  PaymentState({this.payments = const [], this.isLoading = false, this.error});

  PaymentState copyWith({
    List<Payment>? payments,
    bool? isLoading,
    String? error,
  }) {
    return PaymentState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
