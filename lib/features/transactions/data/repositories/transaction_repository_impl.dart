import 'dart:async';

import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._local);
  final TransactionLocalDataSource _local;

  @override
  List<TransactionModel> getAll() {
    final list = _local.getAll();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  TransactionModel? getById(String id) => _local.getById(id);

  @override
  Future<void> add(TransactionModel transaction) => _local.put(transaction);

  @override
  Future<void> update(TransactionModel transaction) => _local.put(transaction);

  @override
  Future<void> delete(String id) => _local.delete(id);

  @override
  Future<void> clear() => _local.clear();

  @override
  Stream<List<TransactionModel>> watchAll() async* {
    yield getAll();
    await for (final _ in _local.watchEvents()) {
      yield getAll();
    }
  }
}
