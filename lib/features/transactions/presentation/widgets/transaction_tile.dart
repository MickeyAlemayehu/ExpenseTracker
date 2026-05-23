import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/entities/transaction_type.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    required this.category,
    required this.currencyCode,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final TransactionModel transaction;
  final CategoryModel? category;
  final String currencyCode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category != null
                    ? Color(category!.colorValue).withOpacity(0.18)
                    : AppColors.mutedLight.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category == null
                    ? Icons.help_outline_rounded
                    : IconData(category!.icon, fontFamily: 'MaterialIcons'),
                color: category != null
                    ? Color(category!.colorValue)
                    : AppColors.mutedLight,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category?.name ?? 'Uncategorized'}  •  ${Formatters.relativeDate(transaction.date)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedLight,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${Formatters.currency(transaction.amount, code: currencyCode)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
