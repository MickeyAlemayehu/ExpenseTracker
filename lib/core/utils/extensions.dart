import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  MediaQueryData get mq => MediaQuery.of(this);
  Size get size => MediaQuery.sizeOf(this);

  void showSnack(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.of(this);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? colors.error : colors.inverseSurface,
        ),
      );
  }
}

extension StringX on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension IterableNumX on Iterable<num> {
  double sumD() => fold<double>(0, (a, b) => a + b.toDouble());
}
