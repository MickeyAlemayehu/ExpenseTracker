import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

/// Snapshot of headline numbers for the dashboard.
class DashboardSummary {
  const DashboardSummary({
    required this.balance,
    required this.income,
    required this.expense,
    required this.monthIncome,
    required this.monthExpense,
    required this.recent,
    required this.byCategory,
  });

  final double balance;
  final double income;
  final double expense;
  final double monthIncome;
  final double monthExpense;
  final List<TransactionModel> recent;
  final List<CategoryBreakdown> byCategory;
}

class CategoryBreakdown {
  const CategoryBreakdown({
    required this.category,
    required this.amount,
  });

  final CategoryModel category;
  final double amount;
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final txns = ref.watch(transactionsProvider);
  final categoriesById = ref.watch(categoriesByIdProvider);
  final now = DateTime.now();
  final monthStart = DateRangeUtils.startOfMonth(now);
  final monthEnd = DateRangeUtils.endOfMonth(now);

  double income = 0;
  double expense = 0;
  double monthIncome = 0;
  double monthExpense = 0;
  final categoryTotals = <String, double>{};

  for (final t in txns) {
    if (t.type == TransactionType.income) {
      income += t.amount;
    } else {
      expense += t.amount;
    }
    if (!t.date.isBefore(monthStart) && !t.date.isAfter(monthEnd)) {
      if (t.type == TransactionType.income) {
        monthIncome += t.amount;
      } else {
        monthExpense += t.amount;
        categoryTotals.update(
          t.categoryId,
          (v) => v + t.amount,
          ifAbsent: () => t.amount,
        );
      }
    }
  }

  final breakdown = categoryTotals.entries
      .map((e) {
        final cat = categoriesById[e.key];
        if (cat == null) return null;
        return CategoryBreakdown(category: cat, amount: e.value);
      })
      .whereType<CategoryBreakdown>()
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  return DashboardSummary(
    balance: income - expense,
    income: income,
    expense: expense,
    monthIncome: monthIncome,
    monthExpense: monthExpense,
    recent: txns.take(5).toList(growable: false),
    byCategory: breakdown.take(6).toList(growable: false),
  );
});
