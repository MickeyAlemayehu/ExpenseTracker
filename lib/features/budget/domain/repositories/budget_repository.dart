import '../../data/models/budget_model.dart';

abstract class BudgetRepository {
  List<BudgetModel> getAll();
  BudgetModel? getById(String id);
  Future<void> add(BudgetModel budget);
  Future<void> update(BudgetModel budget);
  Future<void> delete(String id);
  Stream<List<BudgetModel>> watchAll();
}
