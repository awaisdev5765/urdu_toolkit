# Changelog

## 0.1.0

Initial release.

### Added
- `UrduDigits` — convert between Western and Urdu-Indic digits, and parse
  integers and doubles written in either form. Accepts the Arabic decimal
  separator `٫`.
- `UrduDates` — format Gregorian dates with Urdu month and weekday names and
  Urdu digits.
- `Transliterator` — rule-based Roman-to-Urdu transliteration, longest match
  first, with uppercase letters mapping to retroflex counterparts and a
  word-final special case for `hai`.
- `UrduTextUtils` — detect Arabic-script characters, trim invisible Unicode
  control characters from the edges of a string, and normalise Arabic letter
  variants to their Urdu forms where the mapping is unambiguous.
- `UrduText` — a Flutter widget that applies RTL when the text contains
  Arabic-script characters, and optionally applies a Nastaliq font family to
  Arabic-script glyphs while leaving Latin to the ambient font.
- 41 tests. Zero analyzer issues under strict casts, inference and raw types.
