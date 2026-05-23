import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/transaction_type.dart';
import '../providers/transactions_provider.dart';

/// Add or edit a transaction. Pass [transactionId] for edit mode.
class AddEditTransactionScreen extends ConsumerStatefulWidget {
  const AddEditTransactionScreen({this.transactionId, super.key});
  final String? transactionId;

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _amountCtl = TextEditingController();
  final _notesCtl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  DateTime _date = DateTime.now();
  PaymentMethod _paymentMethod = PaymentMethod.card;
  bool _saving = false;

  bool get _isEdit => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = ref
          .read(transactionRepositoryProvider)
          .getById(widget.transactionId!);
      if (t != null) {
        _titleCtl.text = t.title;
        _amountCtl.text = t.amount.toStringAsFixed(2);
        _notesCtl.text = t.notes ?? '';
        _type = t.type;
        _categoryId = t.categoryId;
        _date = t.date;
        _paymentMethod = t.paymentMethod;
      }
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _amountCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time?.hour ?? _date.hour,
        time?.minute ?? _date.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      context.showSnack('Pick a category', error: true);
      return;
    }
    setState(() => _saving = true);
    final amount = double.parse(_amountCtl.text.trim());
    final id = widget.transactionId ?? _uuid.v4();
    final t = TransactionModel(
      id: id,
      title: _titleCtl.text.trim(),
      amount: amount,
      type: _type,
      categoryId: _categoryId!,
      date: _date,
      paymentMethod: _paymentMethod,
      notes: _notesCtl.text.trim().isEmpty ? null : _notesCtl.text.trim(),
    );
    final controller = ref.read(transactionControllerProvider.notifier);
    if (_isEdit) {
      await controller.update(t);
    } else {
      await controller.add(t);
    }
    if (!mounted) return;
    context.showSnack(_isEdit ? 'Transaction updated' : 'Transaction added');
    context.pop();
  }

  Future<void> _delete() async {
    if (!_isEdit) return;
    final confirmed = await showDialog<bool>(
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
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(transactionControllerProvider.notifier)
        .delete(widget.transactionId!);
    if (!mounted) return;
    context.showSnack('Transaction deleted');
    context.go('/transactions');
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .watch(categoriesProvider)
        .where((c) => c.type == _type)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaction' : 'New Transaction'),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.expense,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _TypeSwitcher(
              type: _type,
              onChanged: (t) => setState(() {
                _type = t;
                _categoryId = null;
              }),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Title',
              hint: 'e.g. Coffee at Starbucks',
              controller: _titleCtl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Amount',
              hint: '0.00',
              controller: _amountCtl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              prefixIcon: Icons.attach_money_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text('Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (categories.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: const Text(
                  'No categories for this type. Add one in the Categories tab.',
                ),
              )
            else
              _CategoryPicker(
                categories: categories,
                selectedId: _categoryId,
                onSelected: (id) => setState(() => _categoryId = id),
              ),
            const SizedBox(height: 20),
            Text('Date & time',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event_rounded),
              label: Text(Formatters.dateTime(_date)),
            ),
            const SizedBox(height: 20),
            Text('Payment method',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in PaymentMethod.values)
                  ChoiceChip(
                    label: Text('${m.icon} ${m.label}'),
                    selected: _paymentMethod == m,
                    onSelected: (_) => setState(() => _paymentMethod = m),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Notes (optional)',
              hint: 'Any details about this transaction',
              controller: _notesCtl,
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: _isEdit ? 'Save changes' : 'Add transaction',
              icon: Icons.check_rounded,
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSwitcher extends StatelessWidget {
  const _TypeSwitcher({required this.type, required this.onChanged});
  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(TransactionType t, String label, Color color, IconData icon) {
      final selected = type == t;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: selected ? Colors.white : AppColors.mutedLight),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.mutedLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          seg(TransactionType.expense, 'Expense', AppColors.expense,
              Icons.arrow_upward_rounded),
          seg(TransactionType.income, 'Income', AppColors.income,
              Icons.arrow_downward_rounded),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in categories)
          GestureDetector(
            onTap: () => onSelected(c.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: selectedId == c.id
                    ? Color(c.colorValue).withOpacity(0.18)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedId == c.id
                      ? Color(c.colorValue)
                      : Theme.of(context).dividerColor,
                  width: selectedId == c.id ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconData(c.icon, fontFamily: 'MaterialIcons'),
                    color: Color(c.colorValue),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(c.name),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
