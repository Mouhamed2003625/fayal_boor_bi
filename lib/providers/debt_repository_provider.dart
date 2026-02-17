import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weer_bi_dena/repositories/debt_repository.dart';
import '../repositories/debt_repository_mysql.dart';


/// Fournit l'instance concrète de PaymentRepository
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepositoryMysql();
});
