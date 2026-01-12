// lib/providers/debt_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/debt_model.dart';
import '../services/debt_repository_mysql.dart';

/// Provider qui récupère la liste des dettes depuis le backend MySQL
final debtListProvider = FutureProvider<List<Debt>>((ref) async {
  final repo = ref.watch(debtRepositoryMySqlProvider);
  return await repo.fetchDebts();
});
