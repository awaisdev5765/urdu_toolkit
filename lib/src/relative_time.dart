/// Urdu relative-time phrases: "۳ منٹ پہلے", "کل", "پرسوں".
///
/// Covers the ranges a chat or feed actually shows — seconds to years — with
/// Urdu-specific day words ([diagram]) that English time-ago packages get
/// wrong: پرسوں (day before yesterday) and نثرں/کل are distinct words, not
/// arithmetic.
library;

/// Urdu relative time formatting.
abstract final class UrduRelativeTime {
  /// Urdu digit glyphs, reused for the count.
  static const String _digits = '۰۱۲۳۴۵۶۷۸۹';

  static String _count(int n) => n
      .toString()
      .split('')
      .map((d) => _digits[int.parse(d)])
      .join();

  static const _minutes = 'منٹ';
  static const _hours = 'گھنٹے';
  static const _days = 'دن';
  static const _weeks = 'ہفتے';
  static const _months = 'مہینے';
  static const _years = 'سال';

  /// Formats [dateTime] relative to [now] (defaults to `DateTime.now()`),
  /// producing phrases like:
  ///
  /// - `ابھی` (just now, under a minute)
  /// - `۵ منٹ پہلے` (5 minutes ago)
  /// - `۲ گھنٹے پہلے`
  /// - `کل` (yesterday), `پرسوں` (day before yesterday)
  /// - `۳ دن پہلے`
  /// - `۲ ہفتے پہلے`
  /// - `۴ مہینے پہلے`
  /// - `پرسال` (last year), `۲ سال پہلے`
  ///
  /// For future timestamps the same scale is used with "بعد" (later):
  /// `۵ منٹ بعد`, `کل`, `پرسوں`-equivalents and so on.
  static String format(
    DateTime dateTime, {
    DateTime? now,
    bool allowTomorrow = true,
  }) {
    final ref = now ?? DateTime.now();
    var delta = dateTime.difference(ref);
    final future = delta.inMinutes > 0;
    final past = !future;
    final abs = delta.abs();

    // Under a minute.
    if (abs.inSeconds < 60) {
      return 'ابھی';
    }

    // Special day words (Urdu counts from "yesterday" differently).
    final today = DateTime(ref.year, ref.month, ref.day);
    final that = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final dayDiff = that.difference(today).inDays;
    // Urdu treats yesterday/tomorrow as one word (کل) and the day on
    // either side of that as one word (پرسوں) — direction does not change
    // the word, only context does.
    if (dayDiff == -1) return 'کل';
    if (dayDiff == -2) return 'پرسوں';
    if (dayDiff == 1) return 'کل';
    if (dayDiff == 2) return 'پرسوں';

    String suffix = past ? 'پہلے' : 'بعد';

    if (abs.inMinutes < 60) {
      return '${_count(abs.inMinutes)} $_minutes $suffix';
    }
    if (abs.inHours < 24) {
      return '${_count(abs.inHours)} $_hours $suffix';
    }
    if (abs.inDays < 7) {
      return '${_count(abs.inDays)} $_days $suffix';
    }
    if (abs.inDays < 30) {
      final weeks = (abs.inDays / 7).floor();
      return '${_count(weeks)} $_weeks $suffix';
    }
    if (abs.inDays < 365) {
      final months = (abs.inDays / 30).floor();
      return '${_count(months)} $_months $suffix';
    }
    final years = (abs.inDays / 365).floor();
    if (years == 1) return past ? 'پرسال' : 'اگلے سال';
    return '${_count(years)} $_years $suffix';
  }
}
