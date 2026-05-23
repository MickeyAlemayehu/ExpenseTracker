import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

/// Side-by-side income vs expense bar chart for the last 6 months.
class MonthlyBars extends ConsumerWidget {
  const MonthlyBars({super.key});

  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txns = ref.watch(transactionsProvider);
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - 5 + i);
      return d;
    });

    final data = months.map((m) {
      final start = DateRangeUtils.startOfMonth(m);
      final end = DateRangeUtils.endOfMonth(m);
      double income = 0;
      double expense = 0;
      for (final t in txns) {
        if (t.date.isBefore(start) || t.date.isAfter(end)) continue;
        if (t.type == TransactionType.income) {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }
      return (month: m, income: income, expense: expense);
    }).toList();

    final maxY = data
        .map((d) => d.income > d.expense ? d.income : d.expense)
        .fold<double>(0, (a, b) => b > a ? b : a);

    final groups = <BarChartGroupData>[];
    for (var i = 0; i < data.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: data[i].income,
              color: AppColors.income,
              width: 8,
              borderRadius: BorderRadius.circular(3),
            ),
            BarChartRodData(
              toY: data[i].expense,
              color: AppColors.expense,
              width: 8,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY == 0 ? 10 : maxY * 1.2,
          barGroups: groups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY == 0 ? 1 : maxY / 3,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Theme.of(context).dividerColor,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _monthLabels[data[i].month.month - 1],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedLight,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
