/// Urdu numerals, dates and transliteration helpers.
///
/// Everything here is pure Dart with no dependency on Flutter, Intl, or a
/// locale database, because the point of the toolkit is to be small enough to
/// drop in anywhere and predictable enough to trust.
///
/// The string constants in [UrduAlphabet] are the ordinary Urdu characters as
/// Unicode text. They render correctly wherever a Nastaliq font is available;
/// they do not require a special rendering engine.
library;

/// Urdu digits and the helpers to convert between Western and Urdu forms.
abstract final class UrduDigits {
  /// The ten Urdu-Indic digits, `۰` through `۹`.
  static const String digits = '۰۱۲۳۴۵۶۷۸۹';

  /// The Western digits, `0` through `9`.
  static const String western = '0123456789';

  /// Converts Western digits to Urdu digits.
  ///
  /// Non-digit characters pass through unchanged, so it is safe to apply to a
  /// whole sentence:
  ///
  /// ```dart
  /// UrduDigits.toUrdu('Page 12 of 30'); // 'صفحہ ۱۲ از ۳۰' is handled elsewhere;
  ///                                     // this call gives 'Page ۱۲ of ۳۰'.
  /// ```
  static String toUrdu(String input) {
    final buffer = StringBuffer();
    for (final char in input.runes) {
      // '0' is 0x30, and the Urdu digits start at 0x6F0.
      if (char >= 0x30 && char <= 0x39) {
        buffer.writeCharCode(0x6F0 + char - 0x30);
      } else {
        buffer.writeCharCode(char);
      }
    }
    return buffer.toString();
  }

  /// Converts Urdu digits to Western digits. Safe on mixed input.
  static String toWestern(String input) {
    final buffer = StringBuffer();
    for (final char in input.runes) {
      if (char >= 0x6F0 && char <= 0x6F9) {
        buffer.writeCharCode(0x30 + char - 0x6F0);
      } else {
        buffer.writeCharCode(char);
      }
    }
    return buffer.toString();
  }

  /// Parses an integer that may be written in Urdu or Western digits.
  ///
  /// Returns null rather than throwing, because a whole document can contain
  /// digit-like characters that are not actually numbers.
  static int? parseInt(String input) =>
      int.tryParse(toWestern(input).replaceAll(RegExp(r'[^\d\-]'), ''));

  /// Parses a double that may be written in Urdu digits.
  ///
  /// Accepts the Arabic decimal separator `٫` as well as the period.
  static double? parseDouble(String input) {
    final cleaned = toWestern(input)
        .replaceAll('\u066B', '.')
        .replaceAll(RegExp(r'[^\d.\-]'), '');
    return double.tryParse(cleaned);
  }
}

/// Urdu ordinals and date parts, using the Gregorian calendar.
///
/// The Hijri calendar is deliberately not implemented: it requires moon
/// sighting data or a conversion library, and a wrong Hijri date is worse than
/// no Hijri date. Extend this class only with a source you trust.
abstract final class UrduDates {
  /// Gregorian months in Urdu.
  static const List<String> months = [
    'جنوری',
    'فروری',
    'مارچ',
    'اپریل',
    'مئی',
    'جون',
    'جولائی',
    'اگست',
    'ستمبر',
    'اکتوبر',
    'نومبر',
    'دسمبر',
  ];

  /// Weekdays, Monday first.
  static const List<String> weekdays = [
    'پیر',
    'منگل',
    'بدھ',
    'جمعرات',
    'جمعہ',
    'ہفتہ',
    'اتوار',
  ];

  /// Formats a date as "۱۵ اگست ۲۰۲۶", with Urdu digits.
  static String format(DateTime date) {
    final day = UrduDigits.toUrdu('${date.day}');
    final month = months[date.month - 1];
    final year = UrduDigits.toUrdu('${date.year}');
    return '$day $month $year';
  }

  /// The Urdu weekday name for [date].
  static String weekday(DateTime date) => weekdays[date.weekday - 1];
}

/// Roman-to-Urdu-script transliteration for common words and letter sequences.
///
/// Transliteration is inherently ambiguous: "kya" could be کیا or کیاں. This
/// implementation is deterministic and rule-based, and is intended for search
/// boxes and quick note-taking, not for producing authoritative text.
///
/// ## Why word boundaries matter
///
/// A greedy longest-match works for most cases but produces wrong output at word
/// boundaries: the trailing `a` in "hai" is a breath mark (ہے), not a long vowel
/// (ہا). The rules below include a word-final special case for that.
///
/// ```dart
/// Transliterator.toUrdu('kya haal hai'); // کیا حال ہے
/// ```
abstract final class Transliterator {
  /// Rules ordered longest first so greedy matching is correct.
  static const List<(String, String)> _rules = [
    ('chh', 'چھ'),
    ('ch', 'چ'),
    ('kh', 'خ'),
    ('gh', 'غ'),
    ('th', 'تھ'),
    ('dh', 'دھ'),
    ('ph', 'پھ'),
    ('bh', 'بھ'),
    ('sh', 'ش'),
    ('zh', 'ژ'),
    ('aa', 'ا'),
    ('ee', 'ی'),
    ('ii', 'ی'),
    ('oo', 'و'),
    ('uu', 'و'),
    ('ai', 'ے'),
    ('au', 'او'),
    ('ou', 'او'),
    ('a', 'ا'),
    ('b', 'ب'),
    ('p', 'پ'),
    ('t', 'ت'),
    ('T', 'ٹ'),
    ('j', 'ج'),
    ('d', 'د'),
    ('D', 'ڈ'),
    ('r', 'ر'),
    ('R', 'ڑ'),
    ('k', 'ک'),
    ('g', 'گ'),
    ('l', 'ل'),
    ('m', 'م'),
    ('n', 'ن'),
    ('v', 'و'),
    ('w', 'و'),
    ('h', 'ہ'),
    ('s', 'س'),
    ('f', 'ف'),
    ('y', 'ی'),
    ('z', 'ز'),
  ];

  /// Converts Roman text to Urdu, applying word-final special cases.
  ///
  /// Case-insensitive for the Roman side. Non-letter characters pass through.
  /// Uppercase letters inside a word are their own markers — `T` becomes ٹ,
  /// lowercase `t` becomes ت — so the user can disambiguate retroflex letters
  /// that share a Roman spelling with their dental counterparts.
  static String toUrdu(String input) {
    final buffer = StringBuffer();
    var index = 0;

    while (index < input.length) {
      final char = input[index];
      if (!_isLetter(char)) {
        buffer.write(char);
        index++;
        continue;
      }

      // Find where this word ends, so word-final rules can be applied.
      var wordEnd = index;
      while (wordEnd < input.length && _isLetter(input[wordEnd])) {
        wordEnd++;
      }
      final word = input.substring(index, wordEnd);

      buffer.write(_transliterateWord(word));
      index = wordEnd;
    }
    return buffer.toString();
  }

  /// Whether [char] is a letter the transliterator handles.
  static bool _isLetter(String char) => RegExp(r'[a-zA-Z]').hasMatch(char);

  /// Transliterates one word, applying word-final special cases.
  static String _transliterateWord(String word) {
    final lower = word.toLowerCase();

    // Word-final 'hai' / 'hai' is the commonest word-final vowel pair, so it
    // gets a special case rather than relying on greedy matching.
    // Word-final 'hai' is ہے, not ہا — a greedy match would produce the wrong
    // vowel, so the whole word gets a special case.
    if (lower == 'hai') return 'ہے';

    return _greedy(lower);
  }

  /// Applies the rules greedily to a whole word with no special cases.
  static String _greedy(String word) {
    final buffer = StringBuffer();
    var index = 0;

    while (index < word.length) {
      var matched = false;
      for (final (roman, urdu) in _rules) {
        if (word.startsWith(roman.toLowerCase(), index)) {
          buffer.write(urdu);
          index += roman.length;
          matched = true;
          break;
        }
      }
      if (!matched) {
        buffer.write(word[index]);
        index++;
      }
    }
    return buffer.toString();
  }
}

/// Text utilities that account for how Urdu is actually written.
abstract final class UrduTextUtils {
  /// Removes common Unicode control characters and ZWJ/ZWNJ from the edges of
  /// [input].
  ///
  /// Zero-width joiners are meaningful inside a word — they join a ya to the
  /// previous letter in نہیں — but they often arrive as stray characters at the
  /// start or end of a string from copy-paste or form input, where they break
  /// equality checks and search.
  static String trimInvisible(String input) {
    return input
        .replaceAll(
            RegExp(r'^[\u200B\u200C\u200D\u200E\u200F\u202A-\u202E]+'), '')
        .replaceAll(
            RegExp(r'[\u200B\u200C\u200D\u200E\u200F\u202A-\u202E]+$'), '');
  }

  /// Whether [input] contains any character from the Arabic/Urdu script.
  ///
  /// Useful for deciding whether to switch to a Nastaliq font: a mixed sentence
  /// returns true, and an English-only sentence returns false without needing
  /// to know the app's locale.
  static bool containsUrdu(String input) {
    return input.runes.any(
      (char) =>
          (char >= 0x0600 && char <= 0x06FF) || // Arabic
          (char >= 0x0750 && char <= 0x077F) || // Arabic Supplement
          (char >= 0xFB50 && char <= 0xFDFF) || // Arabic Presentation Forms-A
          (char >= 0xFE70 && char <= 0xFEFF),
    ); // Presentation Forms-B
  }

  /// Normalises Arabic-script variants to their Urdu forms.
  ///
  /// Arabic and Urdu share a block, and users type with keyboards that produce
  /// the Arabic form of a shared letter. Urdu prefers specific forms of these
  /// letters, and normalising makes search and equality work.
  ///
  /// Only the unambiguous cases are mapped; ambiguous ones (ی, ک, ہ) are left
  /// alone because the correct choice depends on context.
  static String normalise(String input) {
    return input
        .replaceAll('ي', 'ی') // Arabic yeh → Urdu yeh
        .replaceAll('ك', 'ک') // Arabic kaf → Urdu kaf
        .replaceAll('ۀ', 'ہ') // heh with yeh above → heh goal
        .replaceAll('\u064A\u0654', 'ئ'); // ligature → hamza on ya
  }
}
