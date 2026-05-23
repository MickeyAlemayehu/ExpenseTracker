import 'dart:async';

import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._local);
  final BudgetLocalDataSource _local;

  @override
  List<BudgetModel> getAll() {
    final list = _local.getAll();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  @override
  BudgetModel? getById(String id) => _local.getById(id);

  @override
  Future<void> add(BudgetModel budget) => _local.put(budget);

  @override
  Future<void> update(BudgetModel budget) => _local.put(budget);

  @override
  Future<void> delete(String id) => _local.delete(id);

  @override
  Stream<List<BudgetModel>> watchAll() async* {
    yield getAll();
    await for (final _ in _local.watchEvents()) {
      yield getAll();
    }
  }
}
