/// Ergonomic extensions on [String] for Urdu text handling.
///
/// ```dart
/// import 'package:urdu_toolkit/urdu_toolkit.dart';
///
/// final digits = '2026'.urduDigits;          // '۲۰۲۶'
/// final western = '۲۰۲۶'.westernDigits;      // '2026'
/// final clean = 'سلام'.hasUrdu;              // true
/// final bare = 'سَلام'.stripAarab;           // 'سلام'
/// ```
library;

import 'text.dart';

extension UrduStringExtensions on String {
  /// Converts Western digits (0-9) in this string to Urdu digits (۰-۹).
  String get urduDigits => UrduDigits.toUrdu(this);

  /// Converts Urdu digits (۰-۹) in this string to Western digits (0-9).
  String get westernDigits => UrduDigits.toWestern(this);

  /// Whether this string contains any Urdu-script characters.
  bool get hasUrdu => UrduTextUtils.containsUrdu(this);

  /// Removes Urdu diacritics (اعراب: fatha, kasra, damma, etc.).
  String get stripAarab =>
      replaceAll(RegExp('[\u064B-\u065F\u0670]'), '');

  /// Normalises the string for comparison/display (invisible characters
  /// removed, digits unified to Urdu).
  String get urduNormalised => UrduTextUtils.normalise(this);

  /// Whether this string is likely a transliteration target (Latin letters
  /// only).
  bool get isTransliterable => RegExp(r'^[a-zA-Z\s]+$').hasMatch(trim());
}
