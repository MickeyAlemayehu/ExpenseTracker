import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/extensions.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_pad.dart';

/// PIN setup flow: enter, confirm, save.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  static const _pinLength = 4;
  String _entry = '';
  String? _firstEntry;
  String? _error;

  String get _stepLabel =>
      _firstEntry == null ? 'Set a 4-digit PIN' : 'Confirm your PIN';

  void _onDigit(int d) {
    if (_entry.length >= _pinLength) return;
    setState(() {
      _entry = '$_entry$d';
      _error = null;
    });
    if (_entry.length == _pinLength) _maybeSubmit();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _maybeSubmit() async {
    HapticFeedback.lightImpact();
    if (_firstEntry == null) {
      setState(() {
        _firstEntry = _entry;
        _entry = '';
      });
      return;
    }
    if (_firstEntry == _entry) {
      await ref.read(authControllerProvider.notifier).setPin(_entry);
      if (!mounted) return;
      context.showSnack('App lock enabled');
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    } else {
      setState(() {
        _error = "PINs don't match — try again";
        _entry = '';
        _firstEntry = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Lock')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(_stepLabel, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              _error ?? 'This PIN will be required when opening the app.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _error != null
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
              textAlign: TextAlign.center,
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
