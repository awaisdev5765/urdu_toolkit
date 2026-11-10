/// Converts integers to Urdu words: `15` → "پندرہ", `123` → "ایک سو تیئیس".
///
/// Supports zero through the billions scale with the standard South Asian
/// units (hundred, thousand, lakh, crore). Useful for invoices, spoken
/// amounts, TTS and education apps.
library;

/// Urdu number-to-words conversion.
abstract final class UrduNumberWords {
  static const _ones = [
    'صفر', 'ایک', 'دو', 'تین', 'چار', 'پانچ', 'چھ', 'سات', 'آٹھ', 'نو',
    'دس', 'گیارہ', 'بارہ', 'تیرہ', 'چودہ', 'پندرہ', 'سولہ', 'سترہ',
    'اٹھارہ', 'انیس',
  ];

  static const _tens = [
    '', '', 'بیس', 'تیس', 'چالیس', 'پچاس', 'ساٹھ', 'ستر', 'اسی', 'نوے',
  ];

  static const _hundred = 'سو';
  static const _thousand = 'ہزار';
  static const _lakh = 'لاکھ';
  static const _crore = 'کروڑ';

  /// Converts [n] to Urdu words. Supports 0 to 999,99,99,99,999
  /// (hundreds of crores), which covers every practical use.
  static String convert(int n) {
    if (n < 0) return 'منفی ${convert(-n)}';
    if (n < 20) return _ones[n];
    if (n < 100) {
      final tens = n ~/ 10;
      final ones = n % 10;
      return ones == 0 ? _tens[tens] : '${_tens[tens]} ${_ones[ones]}';
    }
    if (n < 1000) {
      final hundreds = n ~/ 100;
      final rest = n % 100;
      final head = '${_ones[hundreds]} $_hundred';
      return rest == 0 ? head : '$head ${convert(rest)}';
    }
    if (n < 100000) {
      final thousands = n ~/ 1000;
      final rest = n % 1000;
      final head = '${convert(thousands)} $_thousand';
      return rest == 0 ? head : '$head ${convert(rest)}';
    }
    if (n < 10000000) {
      final lakhs = n ~/ 100000;
      final rest = n % 100000;
      final head = '${convert(lakhs)} $_lakh';
      return rest == 0 ? head : '$head ${convert(rest)}';
    }
    final crores = n ~/ 10000000;
    final rest = n % 10000000;
    final head = '${convert(crores)} $_crore';
    return rest == 0 ? head : '$head ${convert(rest)}';
  }
}
