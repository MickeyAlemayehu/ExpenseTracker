import 'package:flutter/foundation.dart';

import '../features/categories/data/models/category_model.dart';
import '../features/transactions/data/models/transaction_model.dart';
import '../features/transactions/domain/entities/payment_method.dart';
import '../features/transactions/domain/entities/transaction_type.dart';
import 'export_share_stub.dart'
    if (dart.library.io) 'export_share_io.dart'
    if (dart.library.html) 'export_share_web.dart';

/// CSV export of transactions.
class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  static const List<String> _columns = [
    'Date',
    'Title',
    'Type',
    'Category',
    'Amount',
    'Currency',
    'Payment Method',
    'Notes',
  ];

  /// Build a CSV string from transactions + categories.
  ///
  /// Date is written as ISO `YYYY-MM-DD` so spreadsheet apps don't re-interpret
  /// it as a serial number. Type and payment method are written as
  /// human-readable labels (e.g. "Expense", "Credit Card").
  String buildCsv({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    required String currencyCode,
  }) {
    final byId = {for (final c in categories) c.id: c};
    final buf = StringBuffer()..writeln(_columns.join(','));
    for (final t in transactions) {
      final cat = byId[t.categoryId]?.name ?? 'Uncategorized';
      final row = [
        _isoDate(t.date),
        t.title,
        _typeLabel(t.type),
        cat,
        t.amount.toStringAsFixed(2),
        currencyCode,
        _paymentLabel(t.paymentMethod),
        t.notes ?? '',
      ];
      buf.writeln(row.map(_csv).join(','));
    }
    return buf.toString();
  }

  /// Build the CSV and hand it off to the platform: browser download on web,
  /// native share/save sheet on mobile and desktop.
  Future<void> shareCsv({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    required String currencyCode,
  }) async {
    final csv = buildCsv(
      transactions: transactions,
      categories: categories,
      currencyCode: currencyCode,
    );
    final stamp = _isoDate(DateTime.now());
    final filename = 'transactions_$stamp.csv';
    if (kDebugMode) {
      debugPrint(
        '[export] $filename - ${transactions.length} rows, ${csv.length} chars',
      );
    }
    await saveCsv(csv: csv, filename: filename);
  }

  String _isoDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _typeLabel(TransactionType t) =>
      t == TransactionType.income ? 'Income' : 'Expense';

  String _paymentLabel(PaymentMethod p) => p.label;

  String _csv(String s) {
    if (s.contains(',') ||
        s.contains('"') ||
        s.contains('\n') ||
        s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}
