import 'package:flutter/foundation.dart';

/// Wrapper around `flutter_local_notifications` for budget alerts, bill
/// reminders, and a daily expense logging nudge.
///
/// The current implementation is a no-op stub that logs intent in debug. To
/// enable real notifications:
///   1. Initialize `FlutterLocalNotificationsPlugin` here in [init].
///   2. Request POST_NOTIFICATIONS at runtime on Android 13+.
///   3. Implement [scheduleDailyReminder] / [showBudgetAlert] with the plugin.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    // TODO(prod): initialize FlutterLocalNotificationsPlugin and timezone db.
    if (kDebugMode) {
      debugPrint('NotificationService initialized (stub)');
    }
  }

  Future<bool> requestPermissions() async {
    // TODO(prod): plugin.requestNotificationsPermission()
    return true;
  }

  Future<void> showBudgetAlert({
    required String budgetName,
    required double usedPercent,
  }) async {
    if (kDebugMode) {
      debugPrint('[notif] Budget "$budgetName" at ${usedPercent.toStringAsFixed(0)}%');
    }
  }

  Future<void> scheduleDailyReminder({required int hour}) async {
    if (kDebugMode) {
      debugPrint('[notif] Daily reminder scheduled for ${hour.toString().padLeft(2, '0')}:00');
    }
  }

  Future<void> cancelDailyReminder() async {
    if (kDebugMode) debugPrint('[notif] Daily reminder cancelled');
  }
}
