import '../models/debt_model.dart';

class DebtState {
  final List<Debt> debts;
  final bool isLoading;
  final String? error;

  DebtState({this.debts = const [], this.isLoading = false, this.error});

  DebtState copyWith({List<Debt>? debts, bool? isLoading, String? error}) {
    return DebtState(
      debts: debts ?? this.debts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
