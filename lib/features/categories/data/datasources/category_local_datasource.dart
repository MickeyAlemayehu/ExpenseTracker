import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  CategoryLocalDataSource(this._box);
  final Box<CategoryModel> _box;

  static Future<CategoryLocalDataSource> open() async {
    final box = await Hive.openBox<CategoryModel>(HiveBoxes.categories);
    return CategoryLocalDataSource(box);
  }

  List<CategoryModel> getAll() => _box.values.toList(growable: false);

  CategoryModel? getById(String id) {
    for (final c in _box.values) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> put(CategoryModel c) => _box.put(c.id, c);

  Future<void> delete(String id) => _box.delete(id);

  int get count => _box.length;

  Stream<BoxEvent> watchEvents() => _box.watch();
}
