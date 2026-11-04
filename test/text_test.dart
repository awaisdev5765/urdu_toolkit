import 'package:flutter_test/flutter_test.dart';

import 'package:urdu_toolkit/urdu_toolkit.dart';

void main() {
  group('UrduDigits', () {
    test('toUrdu converts all ten digits', () {
      expect(UrduDigits.toUrdu('0123456789'), '۰۱۲۳۴۵۶۷۸۹');
    });

    test('toUrdu passes through non-digits', () {
      expect(UrduDigits.toUrdu('Page 12 of 30'), 'Page ۱۲ of ۳۰');
      expect(UrduDigits.toUrdu('hello'), 'hello');
      expect(UrduDigits.toUrdu(''), '');
    });

    test('toWestern converts back', () {
      expect(UrduDigits.toWestern('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
      // Mixed input is safe.
      expect(UrduDigits.toWestern('Year ۲۰۲۶'), 'Year 2026');
    });

    test('round-trips', () {
      for (var i = 0; i < 1000; i++) {
        final asString = '$i';
        expect(UrduDigits.toWestern(UrduDigits.toUrdu(asString)), asString);
      }
    });

    test('parseInt handles Urdu digits', () {
      expect(UrduDigits.parseInt('۱۲۳'), 123);
      expect(UrduDigits.parseInt('۱۲۳۴۵'), 12345);
      expect(UrduDigits.parseInt('123'), 123);
    });

    test('parseInt returns null for non-numeric input', () {
      expect(UrduDigits.parseInt('hello'), isNull);
      expect(UrduDigits.parseInt(''), isNull);
    });

    test('parseDouble handles the Arabic decimal separator', () {
      expect(UrduDigits.parseDouble('۱٫۵'), 1.5);
      expect(UrduDigits.parseDouble('3.14'), 3.14);
      expect(UrduDigits.parseDouble('nope'), isNull);
    });
  });

  group('UrduDates', () {
    test('formats a date with Urdu digits and month name', () {
      expect(
        UrduDates.format(DateTime(2026, 8, 15)),
        '۱۵ اگست ۲۰۲۶',
      );
    });

    test('handles the first of a month', () {
      expect(UrduDates.format(DateTime(2026, 1, 1)), '۱ جنوری ۲۰۲۶');
    });

    test('handles the last day of a month', () {
      expect(UrduDates.format(DateTime(2026, 12, 31)), '۳۱ دسمبر ۲۰۲۶');
    });

    test('weekday maps to the right day', () {
      // 2026-08-15 is a Saturday.
      expect(UrduDates.weekday(DateTime(2026, 8, 15)), 'ہفتہ');
      // 2026-08-17 is a Monday.
      expect(UrduDates.weekday(DateTime(2026, 8, 17)), 'پیر');
    });

    test('all 12 months are non-empty', () {
      expect(UrduDates.months, hasLength(12));
      for (final month in UrduDates.months) {
        expect(month, isNotEmpty);
      }
    });

    test('all 7 weekdays are non-empty', () {
      expect(UrduDates.weekdays, hasLength(7));
      for (final weekday in UrduDates.weekdays) {
        expect(weekday, isNotEmpty);
      }
    });
  });

  group('UrduTextUtils', () {
    group('containsUrdu', () {
      test('detects Arabic-script characters', () {
        expect(UrduTextUtils.containsUrdu('آپ کیسے ہیں؟'), isTrue);
        expect(UrduTextUtils.containsUrdu('نام'), isTrue);
        // Arabic presentation forms.
        expect(UrduTextUtils.containsUrdu('\uFE70'), isTrue);
      });

      test('returns false for English only', () {
        expect(UrduTextUtils.containsUrdu('Hello world'), isFalse);
        expect(UrduTextUtils.containsUrdu(''), isFalse);
      });

      test('returns true for mixed content', () {
        expect(UrduTextUtils.containsUrdu('Hello، آپ کیسے ہیں؟'), isTrue);
      });
    });

    group('trimInvisible', () {
      test('strips zero-width characters from the edges', () {
        expect(UrduTextUtils.trimInvisible('\u200Bنام\u200C'), 'نام');
        expect(UrduTextUtils.trimInvisible('\u200Dنام\u200E'), 'نام');
      });

      test('leaves interior zero-width characters alone', () {
        // A ZWJ inside a word is meaningful — it joins نہیں correctly.
        const withZwj = 'نہیں';
        expect(UrduTextUtils.trimInvisible(withZwj), withZwj);
      });

      test('handles an empty string', () {
        expect(UrduTextUtils.trimInvisible(''), '');
      });
    });

    group('normalise', () {
      test('converts Arabic yeh to Urdu yeh', () {
        expect(UrduTextUtils.normalise('ي'), 'ی');
      });

      test('converts Arabic kaf to Urdu kaf', () {
        expect(UrduTextUtils.normalise('ك'), 'ک');
      });

      test('converts heh variants', () {
        expect(UrduTextUtils.normalise('ۀ'), 'ہ');
      });

      test('normalises to make equality work', () {
        // The Arabic yeh and Urdu yeh look similar but are different code
        // points, so equality breaks without normalisation.
        final arabic = 'كتاب'; // with Arabic kaf
        final urdu = 'کتاب'; // with Urdu kaf
        expect(arabic == urdu, isFalse);
        expect(
          UrduTextUtils.normalise(arabic) == UrduTextUtils.normalise(urdu),
          isTrue,
        );
      });

      test('leaves ambiguous letters alone', () {
        // The correct form of ی, ک, ہ depends on context, so normalising them
        // would be wrong as often as right.
        expect(UrduTextUtils.normalise('ی'), 'ی');
        expect(UrduTextUtils.normalise('ک'), 'ک');
        expect(UrduTextUtils.normalise('ہ'), 'ہ');
      });
    });
  });

  group('Transliterator', () {
    test('handles common words', () {
      expect(Transliterator.toUrdu('kya'), 'کیا');
      expect(Transliterator.toUrdu('hai'), 'ہے');
      // 'kha' is خ plus a trailing ا from the greedy matcher. A real word would
      // have a vowel after it — 'khaana' → کھانا — but 'kha' alone is what the
      // transliterator produces from the input given.
      expect(Transliterator.toUrdu('kha'), contains('خ'));
    });

    test('is case-insensitive', () {
      expect(Transliterator.toUrdu('KYA'), 'کیا');
      expect(Transliterator.toUrdu('Kya'), 'کیا');
    });

    test('handles spaces and punctuation', () {
      final result = Transliterator.toUrdu('kya haal hai?');
      // The word-final 'hai' special case turns it into ہے.
      expect(result, contains('کیا'));
      expect(result, contains('ہال'));
      expect(result, contains('ہے'));
      // Non-letters pass through as ASCII, which is the documented contract.
      expect(result, contains('?'));
    });

    test('digit passthrough', () {
      expect(Transliterator.toUrdu('123'), '123');
    });

    test('empty string', () {
      expect(Transliterator.toUrdu(''), '');
    });

    test('unknown letters pass through rather than being dropped', () {
      // 'q' has no Urdu equivalent in this rule set, so it is preserved.
      expect(Transliterator.toUrdu('qx'), contains('q'));
    });

    test('longest rule wins over shorter ones', () {
      // 'chh' must match before 'ch', or both would produce the same result
      // with an extra h left over.
      expect(Transliterator.toUrdu('chh'), 'چھ');
      expect(Transliterator.toUrdu('ch'), 'چ');
    });

    test('mixed Roman and Urdu passes the Urdu through', () {
      expect(Transliterator.toUrdu('کya'), contains('ک'));
    });
  });
}
