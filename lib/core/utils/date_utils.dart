/// Date range + period helpers used by analytics, budget, and dashboard.
class DateRangeUtils {
  DateRangeUtils._();

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  static DateTime startOfWeek(DateTime d) {
    // ISO week — Monday is start.
    final start = d.subtract(Duration(days: d.weekday - 1));
    return startOfDay(start);
  }

  static DateTime endOfWeek(DateTime d) {
    final start = startOfWeek(d);
    return endOfDay(start.add(const Duration(days: 6)));
  }

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month);

  static DateTime endOfMonth(DateTime d) {
    final firstOfNext = (d.month == 12)
        ? DateTime(d.year + 1, 1)
        : DateTime(d.year, d.month + 1);
    return firstOfNext.subtract(const Duration(milliseconds: 1));
  }

  static DateTime startOfYear(DateTime d) => DateTime(d.year);
  static DateTime endOfYear(DateTime d) =>
      DateTime(d.year, 12, 31, 23, 59, 59, 999);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

enum ReportPeriod { week, month, year }

extension ReportPeriodX on ReportPeriod {
  String get label => switch (this) {
        ReportPeriod.week => 'Week',
        ReportPeriod.month => 'Month',
        ReportPeriod.year => 'Year',
      };

  ({DateTime start, DateTime end}) rangeFor(DateTime ref) {
    switch (this) {
      case ReportPeriod.week:
        return (
          start: DateRangeUtils.startOfWeek(ref),
          end: DateRangeUtils.endOfWeek(ref),
        );
      case ReportPeriod.month:
        return (
          start: DateRangeUtils.startOfMonth(ref),
          end: DateRangeUtils.endOfMonth(ref),
        );
      case ReportPeriod.year:
        return (
          start: DateRangeUtils.startOfYear(ref),
          end: DateRangeUtils.endOfYear(ref),
        );
    }
  }
}
