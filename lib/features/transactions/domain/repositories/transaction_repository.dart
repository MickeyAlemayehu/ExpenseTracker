import '../../data/models/transaction_model.dart';

/// Domain contract for transaction persistence. The presentation layer depends
/// on this interface, not the Hive-backed implementation.
abstract class TransactionRepository {
  List<TransactionModel> getAll();
  TransactionModel? getById(String id);
  Future<void> add(TransactionModel transaction);
  Future<void> update(TransactionModel transaction);
  Future<void> delete(String id);
  Future<void> clear();
  Stream<List<TransactionModel>> watchAll();
}
