import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';

class CurrencyPickerScreen extends ConsumerWidget {
  const CurrencyPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currencyCodeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Currency')),
      body: ListView.separated(
        itemBuilder: (context, i) {
          final c = kSupportedCurrencies[i];
          return ListTile(
            leading: SizedBox(
              width: 36,
              child: Text(
                c.symbol,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            title: Text(c.name),
            subtitle: Text(c.code),
            trailing: current == c.code
                ? const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary)
                : null,
            onTap: () async {
              await ref
                  .read(settingsControllerProvider.notifier)
                  .setCurrency(c.code);
              if (context.mounted) context.pop();
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: kSupportedCurrencies.length,
      ),
    );
  }
}
