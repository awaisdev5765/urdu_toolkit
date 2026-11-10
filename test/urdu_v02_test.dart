import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urdu_toolkit/urdu_toolkit.dart';
import 'package:urdu_toolkit/widgets.dart';

void main() {
  group('UrduRelativeTime', () {
    final now = DateTime(2026, 8, 20, 12);

    test('under a minute is ابھی', () {
      expect(
        UrduRelativeTime.format(now.subtract(const Duration(seconds: 30)),
            now: now),
        'ابھی',
      );
    });

    test('minutes ago', () {
      expect(
        UrduRelativeTime.format(
          now.subtract(const Duration(minutes: 5)),
          now: now,
        ),
        '۵ منٹ پہلے',
      );
    });

    test('hours ago', () {
      expect(
        UrduRelativeTime.format(
          now.subtract(const Duration(hours: 2)),
          now: now,
        ),
        '۲ گھنٹے پہلے',
      );
    });

    test('yesterday and tomorrow are both کل', () {
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));
      expect(UrduRelativeTime.format(yesterday, now: now), 'کل');
      expect(UrduRelativeTime.format(tomorrow, now: now), 'کل');
    });

    test('day before yesterday and after tomorrow are پرسوں', () {
      final past = now.subtract(const Duration(days: 2));
      final future = now.add(const Duration(days: 2));
      expect(UrduRelativeTime.format(past, now: now), 'پرسوں');
      expect(UrduRelativeTime.format(future, now: now), 'پرسوں');
    });

    test('days ago', () {
      expect(
        UrduRelativeTime.format(
          now.subtract(const Duration(days: 4)),
          now: now,
        ),
        '۴ دن پہلے',
      );
    });

    test('weeks ago', () {
      expect(
        UrduRelativeTime.format(
          now.subtract(const Duration(days: 14)),
          now: now,
        ),
        '۲ ہفتے پہلے',
      );
    });

    test('months ago', () {
      expect(
        UrduRelativeTime.format(
          now.subtract(const Duration(days: 90)),
          now: now,
        ),
        '۳ مہینے پہلے',
      );
    });

    test('future uses بعد', () {
      expect(
        UrduRelativeTime.format(
          now.add(const Duration(hours: 3)),
          now: now,
        ),
        '۳ گھنٹے بعد',
      );
    });
  });

  group('UrduNumberWords', () {
    test('ones and teens', () {
      expect(UrduNumberWords.convert(0), 'صفر');
      expect(UrduNumberWords.convert(5), 'پانچ');
      expect(UrduNumberWords.convert(15), 'پندرہ');
      expect(UrduNumberWords.convert(19), 'انیس');
    });

    test('tens combinations', () {
      expect(UrduNumberWords.convert(20), 'بیس');
      expect(UrduNumberWords.convert(45), 'چالیس پانچ');
      expect(UrduNumberWords.convert(99), 'نوے نو');
    });

    test('hundreds and thousands', () {
      expect(UrduNumberWords.convert(123), contains('سو'));
      expect(UrduNumberWords.convert(1000), 'ایک ہزار');
      expect(UrduNumberWords.convert(45000), contains('ہزار'));
    });

    test('lakh and crore', () {
      expect(UrduNumberWords.convert(100000), 'ایک لاکھ');
      expect(UrduNumberWords.convert(10000000), 'ایک کروڑ');
    });

    test('negatives', () {
      expect(UrduNumberWords.convert(-5), 'منفی پانچ');
    });
  });

  group('UrduCurrency', () {
    test('formats with Urdu digits and lakh grouping', () {
      expect(UrduCurrency.format(1234567), '۱۲,۳۴,۵۶۷ روپے');
    });

    test('small amounts group normally', () {
      expect(UrduCurrency.format(500), '۵۰۰ روپے');
    });

    test('withWords appends the number in words', () {
      final out = UrduCurrency.format(15, withWords: true);
      expect(out, contains('پندرہ'));
      expect(out, contains('روپے'));
    });

    test('negative amounts', () {
      expect(UrduCurrency.format(-500), contains('-'));
    });
  });

  group('UrduStringExtensions', () {
    test('digits conversion', () {
      expect('2026'.urduDigits, '۲۰۲۶');
      expect('۲۰۲۶'.westernDigits, '2026');
    });

    test('hasUrdu', () {
      expect('آپ کیسے ہیں؟'.hasUrdu, isTrue);
      expect('How are you?'.hasUrdu, isFalse);
    });

    test('stripAarab removes diacritics', () {
      expect('سَلام'.stripAarab, 'سلام');
    });

    test('transliterable check', () {
      expect('kya haal hai'.isTransliterable, isTrue);
      expect('کیا حال ہے'.isTransliterable, isFalse);
    });
  });

  group('UrduTextTheme.nastaliq', () {
    test('multiplies line heights', () {
      final base = ThemeData().textTheme;
      final themed = UrduTextTheme.nastaliq(
        base,
        fontFamily: 'NotoNastaliqUrdu',
      );
      // M3 themes leave fontSize null on bodyMedium (resolved at use).
      final bodySize = base.bodyMedium!.fontSize ?? 14;
      expect(themed.bodyMedium!.height, closeTo(bodySize * 2.0, 0.01));
      expect(themed.bodyMedium!.fontFamily, 'NotoNastaliqUrdu');
    });

    test('keeps existing explicit heights and scales them', () {
      final base = ThemeData()
          .textTheme
          .copyWith(bodyMedium: const TextStyle(fontSize: 16, height: 1.5));
      final themed = UrduTextTheme.nastaliq(base);
      expect(themed.bodyMedium!.height, closeTo(3.0, 0.01));
    });
  });
}
