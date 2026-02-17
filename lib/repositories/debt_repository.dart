import '../models/debt_model.dart';

abstract class DebtRepository {

  Future<List<Debt>> fetchDebts({int? clientId});

  Future<Debt> addDebt(Debt debt);

  Future<Debt> updateDebt(Debt debt);

  Future<void> deleteDebt(int id);

  Future<Debt> markDebtAsPaid({
    required int debtId,
    required DateTime paymentDate,
  });
}
