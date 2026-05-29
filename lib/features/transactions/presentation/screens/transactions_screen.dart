import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/transaction_filter_provider.dart';
import '../widgets/transaction_filter_sheet.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(transactionFilterProvider).search;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txns = ref.watch(filteredTransactionsProvider);
    final filter = ref.watch(transactionFilterProvider);
    final categoriesById = ref.watch(categoriesByIdProvider);
    final code = ref.watch(currencyCodeProvider);

    // Group transactions by day for the section headers.
    final grouped = <DateTime, List<int>>{};
    for (int i = 0; i < txns.length; i++) {
      final t = txns[i];
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      grouped.putIfAbsent(key, () => []).add(i);
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.filter_list_rounded),
                if (!filter.isEmpty)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => const TransactionFilterSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by title or notes',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
              onChanged: (v) =>
                  ref.read(transactionFilterProvider.notifier).setSearch(v),
            ),
          ),
          Expanded(
            child: txns.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions',
                    message: 'Try adjusting filters, or add a new transaction.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, i) {
                      final key = sortedKeys[i];
                      final indexes = grouped[key]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                            child: Text(
                              Formatters.relativeDate(key),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: AppColors.mutedLight),
                            ),
                          ),
                          for (final idx in indexes)
                            TransactionTile(
                              transaction: txns[idx],
                              category: categoriesById[txns[idx].categoryId],
                              currencyCode: code,
                              onTap: () =>
                                  context.push('/transactions/${txns[idx].id}'),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }
}
