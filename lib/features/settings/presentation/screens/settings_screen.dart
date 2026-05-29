import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../services/export_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final currency = kSupportedCurrencies.firstWhere(
      (c) => c.code == s.currencyCode,
      orElse: () => kSupportedCurrencies.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _Section(title: 'Appearance'),
          _Tile(
            icon: Icons.dark_mode_rounded,
            label: 'Theme',
            trailingText: switch (s.themeMode) {
              'light' => 'Light',
              'dark' => 'Dark',
              _ => 'System',
            },
            onTap: () => _showThemePicker(context, ref),
          ),
          _Section(title: 'Money'),
          _Tile(
            icon: Icons.attach_money_rounded,
            label: 'Currency',
            trailingText: '${currency.symbol}  ${currency.code}',
          ),
          _Section(title: 'Security'),
          _SwitchTile(
            icon: Icons.lock_rounded,
            label: 'App lock',
            value: s.appLockEnabled,
            onChanged: (v) async {
              if (v) {
                context.push('/pin-setup');
              } else {
                await ref.read(authControllerProvider.notifier).disableLock();
                if (context.mounted) {
                  context.showSnack('App lock disabled');
                }
              }
            },
          ),
          _Section(title: 'Data'),
          _Tile(
            icon: Icons.file_download_rounded,
            label: 'Export transactions (CSV)',
            onTap: () async {
              final transactions = ref.read(transactionsProvider);
              if (transactions.isEmpty) {
                context.showSnack('No transactions to export.');
                return;
              }
              try {
                await ExportService.instance.shareCsv(
                  transactions: transactions,
                  categories: ref.read(categoriesProvider),
                  currencyCode: s.currencyCode,
                );
              } catch (e) {
                if (context.mounted) {
                  context.showSnack('Export failed: $e');
                }
              }
            },
          ),
          _Section(title: 'About'),
          _Tile(
            icon: Icons.info_outline_rounded,
            label: 'Version',
            trailingText: AppConstants.appVersion,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final current = ref.read(settingsProvider).themeMode;
        Future<void> setMode(String mode) async {
          final tm = switch (mode) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          };
          await ref.read(settingsControllerProvider.notifier).setThemeMode(tm);
          if (ctx.mounted) Navigator.pop(ctx);
        }

        Widget tile(String code, String label, IconData icon) => ListTile(
              leading: Icon(icon),
              title: Text(label),
              trailing: current == code
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => setMode(code),
            );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              tile('system', 'System default', Icons.brightness_auto_rounded),
              tile('light', 'Light', Icons.light_mode_rounded),
              tile('dark', 'Dark', Icons.dark_mode_rounded),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1,
          fontWeight: FontWeight.w700,
          color: AppColors.mutedLight,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    this.trailingText,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: trailingText == null
          ? const Icon(Icons.chevron_right_rounded)
          : Text(
              trailingText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedLight,
                  ),
            ),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      secondary: Icon(icon),
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
