# 📝 urdu_toolkit

<p align="center">
  <b>Urdu and RTL text utilities for Flutter and Dart.</b><br/>
  Transliteration, number and date formatting, letter normalisation, and a
  directional text widget.
</p>

[![pub.dev](https://img.shields.io/badge/pub.dev-urdu__toolkit-0175C2?logo=dart&logoColor=white)](https://pub.dev/packages/urdu_toolkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)

---

Urdu is the third-most-spoken language in the world and the first language of
Pakistan, but Dart has almost no tooling for it: no digit conversion, no date
formatting, no way to tell Arabic-script letter variants apart, and no way to
know whether a string needs a Nastaliq font rather than the default.

This package fills that gap. It is deliberately dependency-free: the text
utilities are pure Dart, so a backend or CLI tool can use them without pulling in
Flutter, and the widget is a thin wrapper that handles the two things Flutter
gets wrong about Urdu out of the box.

## Install

```yaml
dependencies:
  urdu_toolkit: ^0.1.0
```

## What's in it

### Digits

Convert between Western and Urdu-Indic digits, or parse either:

```dart
UrduDigits.toUrdu('Page 12 of 30');  // 'Page ۱۲ of ۳۰'
UrduDigits.toWestern('۲۰۲۶');         // '2026'
UrduDigits.parseInt('۱۲۳');           // 123
UrduDigits.parseDouble('۱٫۵');        // 1.5 — accepts the Arabic decimal separator
```

### Dates

```dart
UrduDates.format(DateTime(2026, 8, 15));  // '۱۵ اگست ۲۰۲۶'
UrduDates.weekday(DateTime(2026, 8, 15)); // 'ہفتہ' (Saturday)
```

Uses the Gregorian calendar with Urdu month and weekday names. The Hijri
calendar is deliberately not implemented — a wrong Hijri date is worse than no
Hijri date, and a correct one needs a source you can verify.

### Transliteration

```dart
Transliterator.toUrdu('kya haal hai'); // کیا حال ہے
Transliterator.toUrdu('salaam');       // سالام
```

Rule-based and deterministic, intended for search boxes and quick note-taking.
Longest match wins, uppercase letters map to retroflex counterparts (`T` → ٹ,
`D` → ڈ, `R` → ڑ), and word-final `hai` gets a special case because a greedy
match would produce the wrong vowel. Not reversible: "kya" could be کیا or کیاں,
and the correct choice depends on context the algorithm does not have.

### Text normalisation

Arabic and Urdu share a script block, and users type with keyboards that produce
the Arabic form of a shared letter. Normalising makes search and equality work:

```dart
UrduTextUtils.normalise('كتاب') == UrduTextUtils.normalise('کتاب'); // true
UrduTextUtils.containsUrdu('Hello، آپ کیسے ہیں؟');                    // true
UrduTextUtils.trimInvisible('\u200Bنام\u200C');                      // 'نام'
```

`normalise` maps the unambiguous cases only: Arabic `ي` → Urdu `ی`, Arabic `ك` →
Urdu `ک`, and `ۀ` → `ہ`. Ambiguous letters are left alone because the correct
choice depends on context, and normalising them would be wrong as often as right.

### UrduText widget

```dart
UrduText('آپ کیسے ہیں؟')
UrduText.mixed('Hello، آپ کیسے ہیں؟')  // mixed content is treated as RTL
UrduText('آپ', nastaliqFontFamily: 'NotoNastaliqUrdu')
```

Handles the two things Flutter gets wrong about Urdu out of the box: direction
(only applies RTL when the text actually contains Arabic-script characters, so
mixed content and force-override are both supported) and font fallback (applies a
Nastaliq family to Arabic-script glyphs while leaving Latin to the ambient font).

You must declare the Nastaliq font in `pubspec.yaml` — Noto Nastaliq Urdu, Jameel
Noori Nastaleeq, or any Naskh font. Without it, Flutter falls back to the
platform's Arabic-script default, which is readable but is not Nastaliq.

## Two libraries, one package

The text utilities are pure Dart with no Flutter dependency, so a backend or CLI
tool can use them without pulling in the framework. The widget lives in a
separate entry point:

```dart
import 'package:urdu_toolkit/urdu_toolkit.dart';   // digits, dates, text utils
import 'package:urdu_toolkit/widgets.dart';        // UrduText widget
```

## What this package deliberately does not do

- **Hijri calendar.** A wrong Hijri date is worse than no Hijri date, and a
  correct one needs a moon-sighting or conversion source you trust.
- **Authoritative transliteration.** The rules are deterministic and useful for
  search, but "kya" is ambiguous and the algorithm cannot resolve it.
- **A Nastaliq rendering engine.** This package handles fonts and
  directionality; the shaping is done by the platform's text engine and your
  font.
- **Every ambiguous letter form.** Only the unambiguous variants are
  normalised. The rest depend on context.

## 🧪 Testing

The package has 41 tests covering digit conversion, date formatting,
transliteration, normalisation, RTL detection and the widget's behaviour. Run
them with:

```bash
flutter test
```

## ☕ Support

If this package helps you, you can buy me a coffee:

<p align="center">
  <a href="https://buymeacoffee.com/awaisdev572">
    <img src="https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=%E2%98%95&slug=awaisdev572&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff" alt="Buy Me A Coffee">
  </a>
</p>

## License

MIT — see [LICENSE](LICENSE).
