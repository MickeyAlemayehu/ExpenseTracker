import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../domain/entities/transaction_type.dart';
import '../providers/transaction_filter_provider.dart';

/// Bottom sheet for filtering transactions by type, category, and date range.
class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  ConsumerState<TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState
    extends ConsumerState<TransactionFilterSheet> {
  late TransactionFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(transactionFilterProvider);
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _draft.from != null && _draft.to != null
          ? DateTimeRange(start: _draft.from!, end: _draft.to!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _draft = _draft.copyWith(from: picked.start, to: picked.end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mutedLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Filter', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _chip('All', _draft.type == null, () {
                    setState(() => _draft = _draft.copyWith(clearType: true));
                  }),
                  _chip('Income', _draft.type == TransactionType.income, () {
                    setState(() => _draft = _draft.copyWith(type: TransactionType.income));
                  }),
                  _chip('Expense', _draft.type == TransactionType.expense, () {
                    setState(() => _draft = _draft.copyWith(type: TransactionType.expense));
                  }),
                ],
              ),
              const SizedBox(height: 20),
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('All', _draft.categoryId == null, () {
                    setState(() => _draft = _draft.copyWith(clearCategory: true));
                  }),
                  for (final c in categories)
                    _chip(c.name, _draft.categoryId == c.id, () {
                      setState(() => _draft = _draft.copyWith(categoryId: c.id));
                    }),
                ],
              ),
              const SizedBox(height: 20),
              Text('Date range', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      onPressed: _pickRange,
                      label: Text(
                        _draft.from == null
                            ? 'Pick dates'
                            : '${Formatters.date(_draft.from!)} → ${Formatters.date(_draft.to!)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (_draft.from != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() => _draft = _draft.copyWith(clearRange: true));
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(transactionFilterProvider.notifier)
                            .clear();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Clear all'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final notifier =
                            ref.read(transactionFilterProvider.notifier);
                        notifier
                          ..setType(_draft.type)
                          ..setCategory(_draft.categoryId)
                          ..setRange(_draft.from, _draft.to);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
