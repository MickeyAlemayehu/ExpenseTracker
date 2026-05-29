import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Reusable on-screen PIN pad.
class PinPad extends StatelessWidget {
  const PinPad({
    required this.onDigit,
    required this.onBackspace,
    super.key,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget digit(int n) => _PinKey(
          label: '$n',
          onTap: () => onDigit(n),
        );

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        digit(1), digit(2), digit(3),
        digit(4), digit(5), digit(6),
        digit(7), digit(8), digit(9),
        const SizedBox.shrink(),
        digit(0),
        _PinKey(
          icon: Icons.backspace_rounded,
          onTap: onBackspace,
        ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Center(
          child: icon != null
              ? Icon(icon, size: 24, color: AppColors.mutedLight)
              : Text(
                  label!,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
        ),
      ),
    );
  }
}

class PinDots extends StatelessWidget {
  const PinDots({required this.length, required this.filled, super.key});

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.18),
            ),
          ),
      ],
    );
  }
}
