/// Urdu and RTL text utilities for Flutter and Dart.
///
/// Two libraries from one package, because not every app needs the widget:
///
/// - **Pure Dart** (`package:urdu_toolkit/urdu_toolkit.dart`) — digits, dates,
///   transliteration and text normalisation. No Flutter dependency.
/// - **Flutter widgets** (`package:urdu_toolkit/widgets.dart`) — `UrduText`,
///   which handles directionality and Nastaliq font fallback. Imports Flutter.
///
/// The split means a backend or CLI tool can use the text utilities without
/// pulling in the framework.
///
/// ## Quick start
///
/// ```dart
/// import 'package:urdu_toolkit/urdu_toolkit.dart';
///
/// UrduDigits.toUrdu('2026');                  // '۲۰۲۶'
/// UrduDates.format(DateTime(2026, 8, 15));    // '۱۵ اگست ۲۰۲۶'
/// Transliterator.toUrdu('kya haal hai');       // 'کیا حال ہے'
/// UrduRelativeTime.format(anHourAgo);          // 'ایک گھنٹے پہلے'
/// UrduNumberWords.convert(15);                 // 'پندرہ'
/// UrduCurrency.format(1234567);                // '۱۲,۳۴,۵۶۷ روپے'
/// '2026'.urduDigits;                           // '۲۰۲۶'
/// ```
///
/// And for Flutter:
///
/// ```dart
/// import 'package:urdu_toolkit/widgets.dart';
///
/// UrduText('آپ کا نام'),
/// ```
library;

export 'src/currency.dart' show UrduCurrency;
export 'src/extensions.dart' show UrduStringExtensions;
export 'src/number_words.dart' show UrduNumberWords;
export 'src/relative_time.dart' show UrduRelativeTime;
export 'src/text.dart'
    show UrduDates, UrduDigits, Transliterator, UrduTextUtils;
export 'src/urdu_text.dart' show UrduText;
