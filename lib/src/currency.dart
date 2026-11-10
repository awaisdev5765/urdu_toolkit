/// Urdu currency formatting with South Asian digit grouping.
///
/// Pakistan and India group digits in 2-2-2 (lakh/crore) rather than the
/// Western 3-3-3, so `Intl`-style formatting produces "1,234,567" where a
/// reader expects "۱۲,۳۴,۵۶۷". This handles both the grouping and the Urdu
/// digits, and appends "روپے" (rupees) by default.
library;

import 'number_words.dart';
import 'text.dart';

/// Urdu currency formatting.
abstract final class UrduCurrency {
  /// Formats [amount] in rupees with Urdu digits and lakh/crore grouping.
  ///
  /// ```dart
  /// UrduCurrency.format(1234567);            // '۱۲,۳۴,۵۶۷ روپے'
  /// UrduCurrency.format(1234567, withWords: true);
  ///                                          // '۱۲ لاکھ چھتیس ہزار پانچ سو سڑسٹھ روپے'
  /// ```
  static String format(
    int amount, {
    bool withWords = false,
    String unit = 'روپے',
    bool negative = false,
  }) {
    final sign = negative || amount < 0 ? '-' : '';
    final grouped = _group(amount.abs().toString());
    final digits = UrduDigits.toUrdu(grouped);
    final words = withWords
        ? ' (${UrduNumberWords.convert(amount.abs())})'
        : '';
    return '$sign$digits $unit$words';
  }

  /// Groups digits South-Asian style: the last three, then pairs.
  static String _group(String digits) {
    if (digits.length <= 3) return digits;
    final last = digits.substring(digits.length - 3);
    final head = digits.substring(0, digits.length - 3);
    final pairs = <String>[];
    var i = head.length;
    while (i > 0) {
      final start = i - 2 < 0 ? 0 : i - 2;
      pairs.insert(0, head.substring(start, i));
      i -= 2;
    }
    return '${pairs.join(',')},$last';
  }
}
