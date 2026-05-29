import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/transaction_type.dart';
import '../providers/transactions_provider.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txn = ref.watch(transactionRepositoryProvider).getById(id);
    if (txn == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Transaction not found',
        ),
      );
    }
    final cat = ref.watch(categoriesByIdProvider)[txn.categoryId];
    final code = ref.watch(currencyCodeProvider);
    final isIncome = txn.type == TransactionType.income;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
        actions: [
          IconButton(
            onPressed: () => context.push('/transactions/${txn.id}/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.expense,
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete transaction?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style:
                          FilledButton.styleFrom(backgroundColor: AppColors.expense),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (ok != true) return;
              await ref
                  .read(transactionControllerProvider.notifier)
                  .delete(txn.id);
              if (context.mounted) {
                context.showSnack('Transaction deleted');
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/transactions');
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: cat == null
                        ? AppColors.mutedLight.withOpacity(0.18)
                        : Color(cat.colorValue).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    cat == null
                        ? Icons.help_outline_rounded
                        : IconData(cat.icon, fontFamily: 'MaterialIcons'),
                    size: 30,
                    color: cat == null
                        ? AppColors.mutedLight
                        : Color(cat.colorValue),
                  ),
                ),
                const SizedBox(height: 12),
                Text(txn.title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${isIncome ? '+' : '-'}${Formatters.currency(txn.amount, code: code)}',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(
                        color: isIncome ? AppColors.income : AppColors.expense,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _DetailCard(rows: [
            (label: 'Type', value: isIncome ? 'Income' : 'Expense'),
            (label: 'Category', value: cat?.name ?? 'Uncategorized'),
            (label: 'Date', value: Formatters.dateTime(txn.date)),
            (label: 'Payment method',  value: txn.paymentMethod.toString()),
            if ((txn.notes ?? '').isNotEmpty)
              (label: 'Notes', value: txn.notes!),
          ]),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.rows});
  final List<({String label, String value})> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        rows[i].label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedLight,
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        rows[i].value,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
