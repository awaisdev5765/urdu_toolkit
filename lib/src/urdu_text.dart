import 'package:flutter/material.dart';

import 'text.dart';

/// A text widget that handles the two things Flutter gets wrong about Urdu out
/// of the box: directionality, and font fallback.
///
/// Flutter's `Text` uses the ambient `Directionality`, which is usually fine —
/// but it is often wrong when the text comes from user input or an API response
/// that can be in either language, and the font fallback for Arabic-script
/// characters differs by platform (Noto Naskh on Android, Geeza Pro on iOS).
///
/// This widget:
/// - Detects whether the text contains Urdu and applies RTL only when needed.
/// - Optionally applies a Nastaliq font for Arabic-script characters while
///   leaving Latin characters to the ambient font, so mixed content reads
///   properly rather than falling back to a serif default.
/// - Normalises Arabic/Urdu letter variants so search and equality work.
/// - Is a plain widget, not a package with a font bundle — you supply the font.
///
/// ```dart
/// UrduText('آپ کا نام'),
/// UrduText.mixed('Hello، آپ کیسے ہیں؟'),
/// ```
class UrduText extends StatelessWidget {
  /// Creates a text widget for Urdu or mixed content.
  const UrduText(
    this.text, {
    super.key,
    this.style,
    this.nastaliqFontFamily,
    this.forceRtl = false,
    this.normalise = true,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textScaler,
  });

  /// The text to display.
  final String text;

  /// Base style. The Nastaliq family is applied on top, so `fontSize`, `color`
  /// and `height` still work.
  final TextStyle? style;

  /// Font family applied when the text contains Urdu characters.
  ///
  /// You must declare the font in `pubspec.yaml` — e.g. Noto Nastaliq Urdu,
  /// Jameel Noori Nastaleeq, or any Naskh font. Without it, Flutter falls back
  /// to the platform's Arabic-script default, which is readable but is not
  /// Nastaliq.
  final String? nastaliqFontFamily;

  /// Forces RTL regardless of content. Only needed for a widget whose text is
  /// known to be Urdu but which contains no Arabic-script characters.
  final bool forceRtl;

  /// Whether to normalise Arabic letter variants to their Urdu forms.
  /// Defaults to true; see [UrduTextUtils.normalise].
  final bool normalise;

  /// How to align the text. Defaults to `TextDirection.ltr`-dependent
  /// behaviour, matching `Text`.
  final TextAlign? textAlign;

  /// Maximum lines before [overflow] applies.
  final int? maxLines;

  /// What to do when the text overflows.
  final TextOverflow? overflow;

  /// Font scaling, passed through to `Text`.
  final TextScaler? textScaler;

  @override
  Widget build(BuildContext context) {
    final effective = normalise ? UrduTextUtils.normalise(text) : text;
    final isUrdu = forceRtl || UrduTextUtils.containsUrdu(effective);

    TextStyle? resolved = style;
    if (isUrdu && nastaliqFontFamily != null) {
      // The Nastaliq family is listed first so Arabic-script glyphs use it, and
      // Latin glyphs fall through to the ambient family.
      resolved = (resolved ?? const TextStyle()).copyWith(
        fontFamilyFallback: [
          nastaliqFontFamily!,
          ...?(resolved?.fontFamilyFallback),
        ],
      );
    }

    return Directionality(
      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
      child: Text(
        effective,
        style: resolved,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        textScaler: textScaler ?? TextScaler.noScaling,
      ),
    );
  }

  /// Whether the widget will be laid out right-to-left.
  bool get isRtl =>
      forceRtl ||
      UrduTextUtils.containsUrdu(
          normalise ? UrduTextUtils.normalise(text) : text);
}
