import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../models/transaction_model.dart';

/// Thin wrapper over the Hive box. Keeps the rest of the app free of Hive APIs.
class TransactionLocalDataSource {
  TransactionLocalDataSource(this._box);
  final Box<TransactionModel> _box;

  static Future<TransactionLocalDataSource> open() async {
    final box = await Hive.openBox<TransactionModel>(HiveBoxes.transactions);
    return TransactionLocalDataSource(box);
  }

  List<TransactionModel> getAll() => _box.values.toList(growable: false);

  TransactionModel? getById(String id) {
    for (final t in _box.values) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<void> put(TransactionModel t) => _box.put(t.id, t);

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();

  Stream<BoxEvent> watchEvents() => _box.watch();
}
