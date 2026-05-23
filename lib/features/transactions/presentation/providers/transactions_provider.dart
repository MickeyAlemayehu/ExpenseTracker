import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

/// Repository binding — overridden in `main.dart` once the Hive box is open.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  throw UnimplementedError(
    'transactionRepositoryProvider must be overridden in main.dart',
  );
});

/// Reactive list of all transactions sorted newest-first.
final transactionsStreamProvider =
    StreamProvider<List<TransactionModel>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchAll();
});

/// Sync view of transactions, useful when we already have them loaded.
final transactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(transactionsStreamProvider).maybeWhen(
        data: (list) => list,
        orElse: () => const [],
      );
});

/// Notifier that exposes write operations to the UI.
class TransactionController extends Notifier<void> {
  late final TransactionRepository _repo;

  @override
  void build() {
    _repo = ref.watch(transactionRepositoryProvider);
  }

  Future<void> add(TransactionModel t) => _repo.add(t);
  Future<void> update(TransactionModel t) => _repo.update(t);
  Future<void> delete(String id) => _repo.delete(id);
}

final transactionControllerProvider =
    NotifierProvider<TransactionController, void>(TransactionController.new);
