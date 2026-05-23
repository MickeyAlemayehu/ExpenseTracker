import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = <_OnboardPage>[
    _OnboardPage(
      icon: Icons.track_changes_rounded,
      title: 'Track every expense',
      subtitle:
          'Log income and expenses with categories, notes and receipts — all on device.',
      tint: AppColors.primary,
    ),
    _OnboardPage(
      icon: Icons.pie_chart_rounded,
      title: 'Visualize your money',
      subtitle:
          'Beautiful charts and reports show where your money goes each week, month, and year.',
      tint: AppColors.secondary,
    ),
    _OnboardPage(
      icon: Icons.savings_rounded,
      title: 'Stay on budget',
      subtitle:
          'Set budgets per category and get alerts before you overspend.',
      tint: AppColors.income,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsControllerProvider.notifier).markOnboardingComplete();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
              ),
            ),
            _Dots(count: _pages.length, active: _page),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: PrimaryButton(
                label: isLast ? 'Get Started' : 'Next',
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
}

class _OnboardPageView extends StatelessWidget {
  const _OnboardPageView({required this.page});
  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: page.tint.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 90, color: page.tint),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedLight,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == active ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
