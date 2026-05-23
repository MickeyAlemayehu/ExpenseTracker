import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../models/budget_model.dart';

class BudgetLocalDataSource {
  BudgetLocalDataSource(this._box);
  final Box<BudgetModel> _box;

  static Future<BudgetLocalDataSource> open() async {
    final box = await Hive.openBox<BudgetModel>(HiveBoxes.budgets);
    return BudgetLocalDataSource(box);
  }

  List<BudgetModel> getAll() => _box.values.toList(growable: false);

  BudgetModel? getById(String id) {
    for (final b in _box.values) {
      if (b.id == id) return b;
    }
    return null;
  }

  Future<void> put(BudgetModel b) => _box.put(b.id, b);
  Future<void> delete(String id) => _box.delete(id);
  Stream<BoxEvent> watchEvents() => _box.watch();
}
