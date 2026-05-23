import '../../data/models/category_model.dart';

abstract class CategoryRepository {
  List<CategoryModel> getAll();
  CategoryModel? getById(String id);
  Future<void> add(CategoryModel category);
  Future<void> update(CategoryModel category);
  Future<void> delete(String id);
  Stream<List<CategoryModel>> watchAll();
  Future<void> seedDefaultsIfEmpty();
}
