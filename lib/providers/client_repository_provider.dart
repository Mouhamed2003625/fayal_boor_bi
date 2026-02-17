import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/client_repository.dart';
import '../repositories/client_repository_mysql.dart';


/// Fournit l'instance concrète de PaymentRepository
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryMySql();
});
