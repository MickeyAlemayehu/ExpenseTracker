import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._local);
  final CategoryLocalDataSource _local;

  static const _uuid = Uuid();

  @override
  List<CategoryModel> getAll() => _local.getAll();

  @override
  CategoryModel? getById(String id) => _local.getById(id);

  @override
  Future<void> add(CategoryModel category) => _local.put(category);

  @override
  Future<void> update(CategoryModel category) => _local.put(category);

  @override
  Future<void> delete(String id) => _local.delete(id);

  @override
  Stream<List<CategoryModel>> watchAll() async* {
    yield getAll();
    await for (final _ in _local.watchEvents()) {
      yield getAll();
    }
  }

  @override
  Future<void> seedDefaultsIfEmpty() async {
    if (_local.count > 0) return;
    final defaults = _defaultCategories();
    for (final c in defaults) {
      await _local.put(c);
    }
  }

  List<CategoryModel> _defaultCategories() {
    final swatches = AppColors.categorySwatches;
    int i = 0;
    Color pick() => swatches[i++ % swatches.length];

    return [
      // Expense categories
      CategoryModel(
        id: _uuid.v4(),
        name: 'Food',
        icon: Icons.restaurant_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.expense,
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Transport',
        icon: Icons.directions_car_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.expense,
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Bills',
        icon: Icons.receipt_long_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.expense,
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Shopping',
        icon: Icons.shopping_bag_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.expense,
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Entertainment',
        icon: Icons.movie_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.expense,
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Health',
        icon: Icons.favorite_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.expense,
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Groceries',
        icon: Icons.local_grocery_store_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.expense,
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Other',
        icon: Icons.category_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.expense,
        isDefault: true,
      ),
      // Income categories
      CategoryModel(
        id: _uuid.v4(),
        name: 'Salary',
        icon: Icons.work_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.income,
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Freelance',
        icon: Icons.laptop_mac_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.income,
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Investments',
        icon: Icons.trending_up_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.income,
        isDefault: true,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Gifts',
        icon: Icons.card_giftcard_rounded.codePoint,
        colorValue: pick().value,
        type: TransactionType.income,
        isDefault: true,
      ),
    ];
  }
}
