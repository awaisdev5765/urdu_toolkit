# Changelog

# Changelog

## 0.2.0

### Added
- `UrduRelativeTime` — chat-ready relative time: "۵ منٹ پہلے", "کل", "پرسوں",
  with future "…بعد" forms and Urdu's directional day words handled correctly
- `UrduNumberWords` — integers to Urdu words ("پندرہ", lakh/crore scale),
  including negatives
- `UrduCurrency` — rupee formatting with South Asian 2-2-2 digit grouping and
  optional in-words expansion: "۱۲,۳۴,۵۶۷ روپے (بارہ لاکھ …)"
- `UrduStringExtensions` — `.urduDigits`, `.westernDigits`, `.hasUrdu`,
  `.stripAarab`, `.urduNormalised`, `.isTransliterable`
- `UrduTextTheme.nastaliq()` — Nastaliq-safe line heights (the script clips
  with Flutter defaults; 2.0 multiplier is the community-recommended value)
- 21 new tests (65 total)

