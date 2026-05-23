import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../data/models/category_model.dart';
import '../providers/categories_provider.dart';

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  const AddEditCategoryScreen({this.categoryId, super.key});
  final String? categoryId;

  @override
  ConsumerState<AddEditCategoryScreen> createState() =>
      _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState
    extends ConsumerState<AddEditCategoryScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  int _iconCode = Icons.shopping_bag_rounded.codePoint;
  int _colorValue = AppColors.primary.value;

  static const _iconChoices = <IconData>[
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.receipt_long_rounded,
    Icons.shopping_bag_rounded,
    Icons.movie_rounded,
    Icons.favorite_rounded,
    Icons.local_grocery_store_rounded,
    Icons.flight_rounded,
    Icons.school_rounded,
    Icons.pets_rounded,
    Icons.home_rounded,
    Icons.fitness_center_rounded,
    Icons.work_rounded,
    Icons.laptop_mac_rounded,
    Icons.trending_up_rounded,
    Icons.card_giftcard_rounded,
    Icons.coffee_rounded,
    Icons.sports_esports_rounded,
    Icons.local_gas_station_rounded,
    Icons.savings_rounded,
  ];

  bool get _isEdit => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final c =
          ref.read(categoryRepositoryProvider).getById(widget.categoryId!);
      if (c != null) {
        _nameCtl.text = c.name;
        _type = c.type;
        _iconCode = c.icon;
        _colorValue = c.colorValue;
      }
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final category = CategoryModel(
      id: widget.categoryId ?? _uuid.v4(),
      name: _nameCtl.text.trim(),
      icon: _iconCode,
      colorValue: _colorValue,
      type: _type,
    );
    final ctl = ref.read(categoryControllerProvider.notifier);
    if (_isEdit) {
      await ctl.update(category);
    } else {
      await ctl.add(category);
    }
    if (!mounted) return;
    context.showSnack(_isEdit ? 'Category updated' : 'Category added');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Category' : 'New Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(_colorValue).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  IconData(_iconCode, fontFamily: 'MaterialIcons'),
                  size: 36,
                  color: Color(_colorValue),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Name',
              hint: 'e.g. Subscriptions',
              controller: _nameCtl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            Text('Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Expense'),
                    selected: _type == TransactionType.expense,
                    onSelected: (_) =>
                        setState(() => _type = TransactionType.expense),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Income'),
                    selected: _type == TransactionType.income,
                    onSelected: (_) =>
                        setState(() => _type = TransactionType.income),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Icon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final icon in _iconChoices)
                  GestureDetector(
                    onTap: () => setState(() => _iconCode = icon.codePoint),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _iconCode == icon.codePoint
                            ? Color(_colorValue).withOpacity(0.18)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _iconCode == icon.codePoint
                              ? Color(_colorValue)
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: _iconCode == icon.codePoint
                            ? Color(_colorValue)
                            : AppColors.mutedLight,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final color in AppColors.categorySwatches)
                  GestureDetector(
                    onTap: () => setState(() => _colorValue = color.value),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _colorValue == color.value
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: _isEdit ? 'Save changes' : 'Add category',
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
