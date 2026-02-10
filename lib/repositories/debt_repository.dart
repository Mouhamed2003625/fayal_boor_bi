
import '../models/debt_model.dart';

abstract class DebtRepository {
  Future<List<Debt>> fetchDebts({
    String? userId,
    String? clientId,
  });

  Future<Debt> addDebt({
    required String clientId,
    required double amount,
    required String description,
    DateTime? dueDate,
    String? paymentMethod,
    String? paymentReference,
    String? notes,
    String? userId,
  });

  Future<Debt> updateDebt(Debt debt);

  Future<void> deleteDebt(int id);

  Future<Debt> markDebtAsPaid({
    required int debtId,
    required DateTime paymentDate,
    String? paymentMethod,
    String? paymentReference,
  });
}
