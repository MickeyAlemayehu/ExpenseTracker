import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../features/budget/data/models/budget_model.dart';
import '../features/categories/data/models/category_model.dart';
import '../features/transactions/data/models/transaction_model.dart';

/// JSON-based backup of all user data. The MVP exposes serialize/deserialize as
/// pure functions — wire them to file IO + share/import flows in production.
class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  static const int version = 1;

  String exportToJson({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    required List<BudgetModel> budgets,
  }) {
    final payload = {
      'version': version,
      'exportedAt': DateTime.now().toIso8601String(),
      'transactions': transactions.map(_transactionToJson).toList(),
      'categories': categories.map(_categoryToJson).toList(),
      'budgets': budgets.map(_budgetToJson).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Returns parsed maps for the caller to feed into repositories. The caller
  /// is responsible for clearing existing state if doing a full restore.
  ({
    List<Map<String, dynamic>> transactions,
    List<Map<String, dynamic>> categories,
    List<Map<String, dynamic>> budgets,
  }) importFromJson(String raw) {
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final v = decoded['version'] as int? ?? 0;
    if (v != version) {
      if (kDebugMode) {
        debugPrint('[backup] version mismatch: file=$v, app=$version');
      }
    }
    return (
      transactions:
          (decoded['transactions'] as List).cast<Map<String, dynamic>>(),
      categories: (decoded['categories'] as List).cast<Map<String, dynamic>>(),
      budgets: (decoded['budgets'] as List).cast<Map<String, dynamic>>(),
    );
  }

  Map<String, dynamic> _transactionToJson(TransactionModel t) => {
        'id': t.id,
        'title': t.title,
        'amount': t.amount,
        'type': t.type.name,
        'categoryId': t.categoryId,
        'date': t.date.toIso8601String(),
        'paymentMethod': t.paymentMethod.name,
        'notes': t.notes,
        'receiptPath': t.receiptPath,
      };

  Map<String, dynamic> _categoryToJson(CategoryModel c) => {
        'id': c.id,
        'name': c.name,
        'icon': c.icon,
        'colorValue': c.colorValue,
        'type': c.type.name,
        'isDefault': c.isDefault,
      };

  Map<String, dynamic> _budgetToJson(BudgetModel b) => {
        'id': b.id,
        'name': b.name,
        'limit': b.limit,
        'period': b.period.name,
        'categoryId': b.categoryId,
        'createdAt': b.createdAt.toIso8601String(),
      };
}
