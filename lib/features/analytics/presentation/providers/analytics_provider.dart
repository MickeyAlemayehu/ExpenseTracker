import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

/// User-selected analytics period.
final analyticsPeriodProvider =
    StateProvider<ReportPeriod>((_) => ReportPeriod.month);

class AnalyticsData {
  const AnalyticsData({
    required this.period,
    required this.income,
    required this.expense,
    required this.byCategory,
    required this.byDay,
  });

  final ReportPeriod period;
  final double income;
  final double expense;
  final List<CategoryBreakdown> byCategory;

  /// Daily totals for the line/bar chart. Sorted by date ascending.
  final List<({DateTime date, double income, double expense})> byDay;

  double get net => income - expense;
}

final analyticsDataProvider = Provider<AnalyticsData>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  final txns = ref.watch(transactionsProvider);
  final catsById = ref.watch(categoriesByIdProvider);
  final range = period.rangeFor(DateTime.now());

  double income = 0;
  double expense = 0;
  final categoryTotals = <String, double>{};
  final dayTotals = <DateTime, ({double income, double expense})>{};

  for (final t in txns) {
    if (t.date.isBefore(range.start) || t.date.isAfter(range.end)) continue;
    if (t.type == TransactionType.income) {
      income += t.amount;
    } else {
      expense += t.amount;
      categoryTotals.update(
        t.categoryId,
        (v) => v + t.amount,
        ifAbsent: () => t.amount,
      );
    }
    final key = DateRangeUtils.startOfDay(t.date);
    final existing = dayTotals[key] ?? (income: 0.0, expense: 0.0);
    dayTotals[key] = t.type == TransactionType.income
        ? (income: existing.income + t.amount, expense: existing.expense)
        : (income: existing.income, expense: existing.expense + t.amount);
  }

  final breakdown = categoryTotals.entries
      .map((e) {
        final cat = catsById[e.key];
        if (cat == null) return null;
        return CategoryBreakdown(category: cat, amount: e.value);
      })
      .whereType<CategoryBreakdown>()
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  final byDay = dayTotals.entries
      .map((e) => (date: e.key, income: e.value.income, expense: e.value.expense))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  return AnalyticsData(
    period: period,
    income: income,
    expense: expense,
    byCategory: breakdown,
    byDay: byDay,
  );
});

/// Plain-English insights derived from the data window.
final analyticsInsightsProvider = Provider<List<String>>((ref) {
  final d = ref.watch(analyticsDataProvider);
  final insights = <String>[];
  if (d.expense == 0 && d.income == 0) {
    insights.add('No activity in this period yet — log a transaction to see insights.');
    return insights;
  }
  if (d.net >= 0) {
    insights.add('You saved ${d.net.toStringAsFixed(2)} this period — keep it up.');
  } else {
    insights.add('You overspent by ${(-d.net).toStringAsFixed(2)} this period.');
  }
  if (d.byCategory.isNotEmpty) {
    final top = d.byCategory.first;
    final share = d.expense > 0 ? (top.amount / d.expense * 100) : 0;
    insights.add(
      '${top.category.name} is your top expense category at ${share.toStringAsFixed(0)}%.',
    );
  }
  if (d.expense > 0 && d.income > 0) {
    final ratio = d.expense / d.income;
    if (ratio > 0.9) {
      insights.add('You spent ${(ratio * 100).toStringAsFixed(0)}% of your income — consider trimming non-essentials.');
    }
  }
  return insights;
});
