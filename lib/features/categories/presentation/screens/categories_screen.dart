import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../../data/models/category_model.dart';
import '../providers/categories_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final expenses =
        categories.where((c) => c.type == TransactionType.expense).toList();
    final incomes =
        categories.where((c) => c.type == TransactionType.income).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: categories.isEmpty
            ? const EmptyState(
                icon: Icons.category_outlined,
                title: 'No categories yet',
                message: 'Tap + to add your first category.',
              )
            : TabBarView(
                children: [
                  _CategoryGrid(items: expenses),
                  _CategoryGrid(items: incomes),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/categories/new'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add'),
        ),
      ),
    );
  }
}

class _CategoryGrid extends ConsumerWidget {
  const _CategoryGrid({required this.items});
  final List<CategoryModel> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.category_outlined,
        title: 'None yet',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final c = items[i];
        return InkWell(
          onTap: () => context.push('/categories/${c.id}/edit'),
          borderRadius: BorderRadius.circular(16),
          onLongPress: () async {
            if (c.isDefault) {
              context.showSnack(
                'Default categories cannot be deleted',
                error: true,
              );
              return;
            }
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Delete "${c.name}"?'),
                content: const Text(
                  'Transactions in this category will become uncategorized.',
                ),
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
            if (ok == true) {
              await ref
                  .read(categoryControllerProvider.notifier)
                  .delete(c.id);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(c.colorValue).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    IconData(c.icon, fontFamily: 'MaterialIcons'),
                    color: Color(c.colorValue),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
