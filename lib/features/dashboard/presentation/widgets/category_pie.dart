import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/dashboard_provider.dart';

/// Pie chart over the top expense categories for the current month.
class CategoryPie extends ConsumerWidget {
  const CategoryPie({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final code = ref.watch(currencyCodeProvider);
    final breakdown = summary.byCategory;

    if (breakdown.isEmpty) {
      return _emptyState(context);
    }

    final total = breakdown.fold<double>(0, (a, b) => a + b.amount);
    final sections = <PieChartSectionData>[];
    for (final b in breakdown) {
      final pct = total == 0 ? 0 : (b.amount / total * 100);
      sections.add(
        PieChartSectionData(
          value: b.amount,
          color: Color(b.category.colorValue),
          radius: 56,
          showTitle: pct >= 8,
          title: '${pct.toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 36,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...breakdown.take(4).map(
              (b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(b.category.colorValue),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(b.category.name)),
                    Text(Formatters.currency(b.amount, code: code)),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      child: Text(
        'No expenses yet this month',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedLight,
            ),
      ),
    );
  }
}
