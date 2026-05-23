import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction_model.dart';
import '../../domain/entities/transaction_type.dart';
import 'transactions_provider.dart';

/// Filter state for the transactions list screen.
class TransactionFilter {
  const TransactionFilter({
    this.search = '',
    this.type,
    this.categoryId,
    this.from,
    this.to,
  });

  final String search;
  final TransactionType? type;
  final String? categoryId;
  final DateTime? from;
  final DateTime? to;

  bool get isEmpty =>
      search.isEmpty &&
      type == null &&
      categoryId == null &&
      from == null &&
      to == null;

  TransactionFilter copyWith({
    String? search,
    TransactionType? type,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    bool clearType = false,
    bool clearCategory = false,
    bool clearRange = false,
  }) {
    return TransactionFilter(
      search: search ?? this.search,
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      from: clearRange ? null : (from ?? this.from),
      to: clearRange ? null : (to ?? this.to),
    );
  }
}

class TransactionFilterController extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setSearch(String value) => state = state.copyWith(search: value);
  void setType(TransactionType? t) =>
      state = state.copyWith(type: t, clearType: t == null);
  void setCategory(String? id) =>
      state = state.copyWith(categoryId: id, clearCategory: id == null);
  void setRange(DateTime? from, DateTime? to) =>
      state = state.copyWith(
        from: from,
        to: to,
        clearRange: from == null && to == null,
      );
  void clear() => state = const TransactionFilter();
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterController, TransactionFilter>(
  TransactionFilterController.new,
);

/// Derived: transactions after applying the current filter.
final filteredTransactionsProvider =
    Provider<List<TransactionModel>>((ref) {
  final all = ref.watch(transactionsProvider);
  final f = ref.watch(transactionFilterProvider);
  if (f.isEmpty) return all;

  final q = f.search.trim().toLowerCase();
  return all.where((t) {
    if (f.type != null && t.type != f.type) return false;
    if (f.categoryId != null && t.categoryId != f.categoryId) return false;
    if (f.from != null && t.date.isBefore(f.from!)) return false;
    if (f.to != null && t.date.isAfter(f.to!)) return false;
    if (q.isNotEmpty) {
      final hay = '${t.title} ${t.notes ?? ''}'.toLowerCase();
      if (!hay.contains(q)) return false;
    }
    return true;
  }).toList(growable: false);
});
