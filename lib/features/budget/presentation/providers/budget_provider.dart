import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../data/models/budget_model.dart';
import '../../domain/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  throw UnimplementedError(
    'budgetRepositoryProvider must be overridden in main.dart',
  );
});

final budgetsStreamProvider =
    StreamProvider<List<BudgetModel>>((ref) {
  return ref.watch(budgetRepositoryProvider).watchAll();
});

final budgetsProvider = Provider<List<BudgetModel>>((ref) {
  return ref.watch(budgetsStreamProvider).maybeWhen(
        data: (list) => list,
        orElse: () => const [],
      );
});

class BudgetUsage {
  const BudgetUsage({
    required this.budget,
    required this.spent,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final BudgetModel budget;
  final double spent;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  double get remaining => (budget.limit - spent).clamp(0, double.infinity);
  double get percent =>
      budget.limit <= 0 ? 0 : (spent / budget.limit).clamp(0, 1).toDouble();
  bool get isOver => spent > budget.limit;
  bool get isNear => percent >= 0.8 && !isOver;
}

/// Compute live usage per budget by intersecting the period range with all
/// matching expense transactions.
final budgetUsageProvider = Provider<List<BudgetUsage>>((ref) {
  final budgets = ref.watch(budgetsProvider);
  final txns = ref.watch(transactionsProvider);
  final now = DateTime.now();

  ({DateTime start, DateTime end}) rangeFor(BudgetModel b) {
    switch (b.period) {
      case BudgetPeriod.weekly:
        return (
          start: DateRangeUtils.startOfWeek(now),
          end: DateRangeUtils.endOfWeek(now),
        );
      case BudgetPeriod.monthly:
        return (
          start: DateRangeUtils.startOfMonth(now),
          end: DateRangeUtils.endOfMonth(now),
        );
      case BudgetPeriod.yearly:
        return (
          start: DateRangeUtils.startOfYear(now),
          end: DateRangeUtils.endOfYear(now),
        );
    }
  }

  return budgets.map((b) {
    final r = rangeFor(b);
    final spent = txns
        .where((t) =>
            t.type == TransactionType.expense &&
            !t.date.isBefore(r.start) &&
            !t.date.isAfter(r.end) &&
            (b.categoryId == null || t.categoryId == b.categoryId))
        .fold<double>(0, (sum, TransactionModel t) => sum + t.amount);
    return BudgetUsage(
      budget: b,
      spent: spent,
      rangeStart: r.start,
      rangeEnd: r.end,
    );
  }).toList(growable: false);
});

class BudgetController extends Notifier<void> {
  late final BudgetRepository _repo;

  @override
  void build() {
    _repo = ref.watch(budgetRepositoryProvider);
  }

  Future<void> add(BudgetModel b) => _repo.add(b);
  Future<void> update(BudgetModel b) => _repo.update(b);
  Future<void> delete(String id) => _repo.delete(id);
}

final budgetControllerProvider =
    NotifierProvider<BudgetController, void>(BudgetController.new);
