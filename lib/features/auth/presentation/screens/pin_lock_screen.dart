import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/pin_pad.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  static const _pinLength = 4;
  String _entry = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    if (auth.status == AuthStatus.needsSetup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/pin-setup');
      });
    }
  }

  void _onDigit(int d) {
    if (_entry.length >= _pinLength) return;
    setState(() {
      _entry = '$_entry$d';
      _error = null;
    });
    if (_entry.length == _pinLength) _submit();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  void _submit() {
    final ok = ref.read(authControllerProvider.notifier).unlockWithPin(_entry);
    if (ok) {
      HapticFeedback.lightImpact();
      context.go('/home');
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        _error = 'Incorrect PIN';
        _entry = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Icon(
              Icons.lock_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Enter your PIN',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unlock Expense Tracker',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _error != null
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
            ),
            const SizedBox(height: 40),
            PinDots(length: _pinLength, filled: _entry.length),
            const Spacer(),
            PinPad(
              onDigit: _onDigit,
              onBackspace: _onBackspace,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
