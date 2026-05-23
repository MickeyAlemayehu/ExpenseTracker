import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/models/budget_model.dart';
import '../providers/budget_provider.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usages = ref.watch(budgetUsageProvider);
    final code = ref.watch(currencyCodeProvider);
    final categoriesById = ref.watch(categoriesByIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: usages.isEmpty
          ? const EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No budgets yet',
              message: 'Set spending limits to stay on track.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemBuilder: (context, i) {
                final u = usages[i];
                final cat = u.budget.categoryId == null
                    ? null
                    : categoriesById[u.budget.categoryId];
                return _BudgetCard(
                  budget: u.budget,
                  spent: u.spent,
                  percent: u.percent,
                  isOver: u.isOver,
                  isNear: u.isNear,
                  categoryName: cat?.name ?? 'All categories',
                  color: cat == null ? AppColors.primary : Color(cat.colorValue),
                  currencyCode: code,
                  onTap: () =>
                      context.go('/budgets/${u.budget.id}/edit'),
                  onDelete: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete budget?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.expense,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref
                          .read(budgetControllerProvider.notifier)
                          .delete(u.budget.id);
                      if (context.mounted) {
                        context.showSnack('Budget deleted');
                      }
                    }
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: usages.length,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/budgets/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New budget'),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.percent,
    required this.isOver,
    required this.isNear,
    required this.categoryName,
    required this.color,
    required this.currencyCode,
    required this.onTap,
    required this.onDelete,
  });

  final BudgetModel budget;
  final double spent;
  final double percent;
  final bool isOver;
  final bool isNear;
  final String categoryName;
  final Color color;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Color get _barColor =>
      isOver ? AppColors.expense : (isNear ? AppColors.warning : color);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onDelete,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$categoryName  •  ${budget.period.label}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedLight,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isOver)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'OVER',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else if (isNear)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'NEAR',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: _barColor.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(_barColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  Formatters.currency(spent, code: currencyCode),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  ' of ${Formatters.currency(budget.limit, code: currencyCode)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedLight,
                      ),
                ),
                const Spacer(),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _barColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
