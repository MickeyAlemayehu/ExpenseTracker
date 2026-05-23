import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  throw UnimplementedError(
    'categoryRepositoryProvider must be overridden in main.dart',
  );
});

final categoriesStreamProvider =
    StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(categoriesStreamProvider).maybeWhen(
        data: (list) => list,
        orElse: () => const [],
      );
});

/// Lookup by id without iterating the list at every call site.
final categoriesByIdProvider = Provider<Map<String, CategoryModel>>((ref) {
  return {for (final c in ref.watch(categoriesProvider)) c.id: c};
});

class CategoryController extends Notifier<void> {
  late final CategoryRepository _repo;

  @override
  void build() {
    _repo = ref.watch(categoryRepositoryProvider);
  }

  Future<void> add(CategoryModel c) => _repo.add(c);
  Future<void> update(CategoryModel c) => _repo.update(c);
  Future<void> delete(String id) => _repo.delete(id);
}

final categoryControllerProvider =
    NotifierProvider<CategoryController, void>(CategoryController.new);
