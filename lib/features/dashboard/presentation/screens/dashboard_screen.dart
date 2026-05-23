import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/category_pie.dart';
import '../widgets/monthly_bars.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final code = ref.watch(currencyCodeProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              _Header(),
              const SizedBox(height: 20),
              _BalanceCard(
                balance: summary.balance,
                monthIncome: summary.monthIncome,
                monthExpense: summary.monthExpense,
                code: code,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Income (total)',
                      value: Formatters.currency(summary.income, code: code),
                      icon: Icons.arrow_downward_rounded,
                      tint: AppColors.income,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Expense (total)',
                      value: Formatters.currency(summary.expense, code: code),
                      icon: Icons.arrow_upward_rounded,
                      tint: AppColors.expense,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Monthly trend',
                trailing: 'Analytics',
                onTrailingTap: () => context.go('/analytics'),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: const MonthlyBars(),
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'This month by category',
                trailing: 'See all',
                onTrailingTap: () => context.go('/analytics'),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: const CategoryPie(),
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Recent transactions',
                trailing: 'View all',
                onTrailingTap: () => context.go('/transactions'),
              ),
              const SizedBox(height: 8),
              if (summary.recent.isEmpty)
                EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No transactions yet',
                  message: 'Tap the + button to add your first transaction.',
                )
              else
                ...summary.recent.map((t) => _RecentTile(transaction: t)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/transactions/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = switch (now.hour) {
      < 12 => 'Good morning',
      < 17 => 'Good afternoon',
      _ => 'Good evening',
    };
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedLight,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.monthYear(now),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.monthIncome,
    required this.monthExpense,
    required this.code,
  });

  final double balance;
  final double monthIncome;
  final double monthExpense;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.currency(balance, code: code),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _BalanceCardMini(
                  label: 'Income',
                  value: Formatters.currency(monthIncome, code: code),
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _BalanceCardMini(
                  label: 'Expense',
                  value: Formatters.currency(monthExpense, code: code),
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceCardMini extends StatelessWidget {
  const _BalanceCardMini({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentTile extends ConsumerWidget {
  const _RecentTile({required this.transaction});
  final TransactionModel transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(currencyCodeProvider);
    final cat = ref.watch(categoriesByIdProvider)[transaction.categoryId];
    final isIncome = transaction.type == TransactionType.income;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => context.go('/transactions/${transaction.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cat != null
                      ? Color(cat.colorValue).withOpacity(0.18)
                      : AppColors.mutedLight.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  cat == null
                      ? Icons.help_outline_rounded
                      : IconData(cat.icon, fontFamily: 'MaterialIcons'),
                  color: cat != null
                      ? Color(cat.colorValue)
                      : AppColors.mutedLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cat?.name ?? 'Uncategorized'}  •  ${Formatters.relativeDate(transaction.date)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedLight,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${Formatters.currency(transaction.amount, code: code)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isIncome ? AppColors.income : AppColors.expense,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
