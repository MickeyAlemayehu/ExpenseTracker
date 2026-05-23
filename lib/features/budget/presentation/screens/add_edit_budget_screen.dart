import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../data/models/budget_model.dart';
import '../providers/budget_provider.dart';

class AddEditBudgetScreen extends ConsumerStatefulWidget {
  const AddEditBudgetScreen({this.budgetId, super.key});
  final String? budgetId;

  @override
  ConsumerState<AddEditBudgetScreen> createState() =>
      _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends ConsumerState<AddEditBudgetScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _limitCtl = TextEditingController();

  BudgetPeriod _period = BudgetPeriod.monthly;
  String? _categoryId;

  bool get _isEdit => widget.budgetId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final b = ref.read(budgetRepositoryProvider).getById(widget.budgetId!);
      if (b != null) {
        _nameCtl.text = b.name;
        _limitCtl.text = b.limit.toStringAsFixed(2);
        _period = b.period;
        _categoryId = b.categoryId;
      }
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _limitCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final b = BudgetModel(
      id: widget.budgetId ?? _uuid.v4(),
      name: _nameCtl.text.trim(),
      limit: double.parse(_limitCtl.text.trim()),
      period: _period,
      categoryId: _categoryId,
    );
    final ctl = ref.read(budgetControllerProvider.notifier);
    if (_isEdit) {
      await ctl.update(b);
    } else {
      await ctl.add(b);
    }
    if (!mounted) return;
    context.showSnack(_isEdit ? 'Budget updated' : 'Budget added');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = ref
        .watch(categoriesProvider)
        .where((c) => c.type == TransactionType.expense)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Budget' : 'New Budget'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            AppTextField(
              label: 'Name',
              hint: 'e.g. Eating out',
              controller: _nameCtl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Limit',
              hint: '0.00',
              controller: _limitCtl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              prefixIcon: Icons.attach_money_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) return 'Enter a valid limit';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text('Period', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final p in BudgetPeriod.values)
                  ChoiceChip(
                    label: Text(p.label),
                    selected: _period == p,
                    onSelected: (_) => setState(() => _period = p),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All expenses'),
                  selected: _categoryId == null,
                  onSelected: (_) => setState(() => _categoryId = null),
                ),
                for (final c in expenseCategories)
                  ChoiceChip(
                    label: Text(c.name),
                    selected: _categoryId == c.id,
                    onSelected: (_) => setState(() => _categoryId = c.id),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: _isEdit ? 'Save changes' : 'Add budget',
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
