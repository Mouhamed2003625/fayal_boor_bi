import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/payment_repository.dart';
import '../repositories/payment_repository_mysql.dart'; // ton implémentation concrète

/// Fournit l'instance concrète de PaymentRepository
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryMySql();
});
