import '../models/payment_model.dart';

/// Interface abstraite pour le repository de paiement
abstract class PaymentRepository {
  /// Récupérer tous les paiements d'une dette
  Future<List<Payment>> getPaymentsByDebt(int debtId);

  /// Récupérer tous les paiements (tous les clients)
  Future<List<Payment>> getAllPayments(); // 🔹 ajoutée

  /// Créer un paiement
  Future<Payment> createPayment(Payment payment);

  /// Mettre à jour un paiement
  Future<Payment> updatePayment(Payment payment);

  /// Supprimer un paiement
  Future<void> deletePayment(int id);
}
