import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsDataProvider);
    final period = ref.watch(analyticsPeriodProvider);
    final code = ref.watch(currencyCodeProvider);
    final insights = ref.watch(analyticsInsightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _PeriodSelector(
            selected: period,
            onChanged: (p) =>
                ref.read(analyticsPeriodProvider.notifier).state = p,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Income',
                  value: Formatters.currency(data.income, code: code),
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Expense',
                  value: Formatters.currency(data.expense, code: code),
                  color: AppColors.expense,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Net',
                  value: Formatters.currency(data.net, code: code),
                  color: data.net >= 0 ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Income vs Expense',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _TrendChart(data: data),
            ),
          ),
          const SizedBox(height: 24),
          Text('Expenses by category',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (data.byCategory.isEmpty)
            const EmptyState(
              icon: Icons.donut_large_outlined,
              title: 'No expenses in this period',
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _CategoryDonut(data: data, code: code),
              ),
            ),
          const SizedBox(height: 24),
          if (insights.isNotEmpty) ...[
            Text('Insights', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final i in insights) _InsightCard(text: i),
          ],
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});
  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          for (final p in ReportPeriod.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        selected == p ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    p.label,
                    style: TextStyle(
                      color: selected == p ? Colors.white : AppColors.mutedLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.data});
  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    if (data.byDay.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          'No activity in this period',
          style: TextStyle(color: AppColors.mutedLight),
        ),
      );
    }

    final maxY = data.byDay
        .map((d) => d.income > d.expense ? d.income : d.expense)
        .fold<double>(0, (a, b) => b > a ? b : a);

    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    for (var i = 0; i < data.byDay.length; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), data.byDay[i].income));
      expenseSpots.add(FlSpot(i.toDouble(), data.byDay[i].expense));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY == 0 ? 10 : maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY == 0 ? 1 : maxY / 3,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Theme.of(context).dividerColor,
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: incomeSpots,
              color: AppColors.income,
              barWidth: 3,
              isCurved: true,
              curveSmoothness: 0.25,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.income.withOpacity(0.15),
              ),
            ),
            LineChartBarData(
              spots: expenseSpots,
              color: AppColors.expense,
              barWidth: 3,
              isCurved: true,
              curveSmoothness: 0.25,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.expense.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDonut extends StatelessWidget {
  const _CategoryDonut({required this.data, required this.code});
  final AnalyticsData data;
  final String code;

  @override
  Widget build(BuildContext context) {
    final total = data.expense;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 50,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              sections: [
                for (final b in data.byCategory)
                  PieChartSectionData(
                    value: b.amount,
                    color: Color(b.category.colorValue),
                    radius: 56,
                    showTitle: total > 0 && (b.amount / total) >= 0.08,
                    title:
                        '${(total > 0 ? (b.amount / total * 100) : 0).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...data.byCategory.map(
          (b) {
            final pct = total > 0 ? (b.amount / total * 100) : 0;
            return Padding(
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
                  Text('${pct.toStringAsFixed(0)}%',
                      style: TextStyle(color: AppColors.mutedLight)),
                  const SizedBox(width: 12),
                  Text(Formatters.currency(b.amount, code: code)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
