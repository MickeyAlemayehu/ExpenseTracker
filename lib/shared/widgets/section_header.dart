import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.trailing,
    this.onTrailingTap,
    super.key,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (trailing != null)
          TextButton(
            onPressed: onTrailingTap,
            child: Text(trailing!),
          ),
      ],
    );
  }
}
