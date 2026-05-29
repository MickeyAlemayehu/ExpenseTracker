import 'package:flutter/foundation.dart';

import '../core/utils/formatters.dart';
import '../features/categories/data/models/category_model.dart';
import '../features/transactions/data/models/transaction_model.dart';

/// CSV / PDF export of transactions. CSV is fully implemented; PDF is stubbed
/// (drop in the `pdf` + `printing` packages to wire it up).
class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  /// Build a CSV string from transactions + categories. Returns the raw text so
  /// the caller can write to a file or share via `share_plus`.
  String buildCsv({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    String currencyCode = 'ETB',
  }) {
    final byId = {for (final c in categories) c.id: c};
    final buf = StringBuffer()
      ..writeln('Date,Title,Type,Category,Amount,Payment Method,Notes');
    for (final t in transactions) {
      final cat = byId[t.categoryId]?.name ?? 'Uncategorized';
      buf
        ..write(_csv(Formatters.date(t.date)))
        ..write(',')
        ..write(_csv(t.title))
        ..write(',')
        ..write(_csv(t.type.name))
        ..write(',')
        ..write(_csv(cat))
        ..write(',')
        ..write(_csv(t.amount.toStringAsFixed(2)))
        ..write(',')
        ..write(_csv(t.paymentMethod.name))
        ..write(',')
        ..write(_csv(t.notes ?? ''))
        ..writeln();
    }
    return buf.toString();
  }

  /// Stubbed PDF export. Implementation:
  ///   - add `pdf: ^3.11.0` + `printing: ^5.13.0` to pubspec
  ///   - build `pw.Document()`, add pages with a `pw.Table` from transactions
  ///   - return `await doc.save()` as bytes
  Future<List<int>> buildPdf({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
  }) async {
    if (kDebugMode) debugPrint('[export] PDF stub — add `pdf` package');
    return const <int>[];
  }

  String _csv(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}
