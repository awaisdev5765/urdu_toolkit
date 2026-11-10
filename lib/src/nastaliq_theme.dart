import 'package:flutter/material.dart';

/// A pre-wired [TextTheme] tuned for Nastaliq script.
///
/// Nastaliq is a hanging script with deep descenders: rendered with Flutter's
/// default line height it clips letters vertically and overlaps lines. This
/// theme multiplies every style's height by [lineHeightMultiplier] (defaults
/// to 2.0, the value the Nastaliq type community recommends for body text)
/// and optionally injects a Nastaliq font family.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     fontFamily: 'NotoNastaliqUrdu',
///     textTheme: UrduTextTheme.nastaliq(baseTheme),
///   ),
/// )
/// ```
class UrduTextTheme {
  /// Applies Nastaliq-safe line heights to every style in [base].
  ///
  /// [fontFamily] is applied to every style that does not already set one;
  /// pass null to keep the ambient family. [lineHeightMultiplier] scales
  /// each style's explicit height, or the font size when no height is set.
  static TextTheme nastaliq(
    TextTheme base, {
    String? fontFamily,
    double lineHeightMultiplier = 2.0,
  }) {
    TextStyle? tune(TextStyle? style) {
      if (style == null) return null;
      final size = style.fontSize ?? 14;
      final height = style.height != null
          ? style.height! * lineHeightMultiplier
          : size * lineHeightMultiplier;
      return style.copyWith(
        fontFamily: fontFamily ?? style.fontFamily,
        height: height,
      );
    }

    return base.copyWith(
      displayLarge: tune(base.displayLarge),
      displayMedium: tune(base.displayMedium),
      displaySmall: tune(base.displaySmall),
      headlineLarge: tune(base.headlineLarge),
      headlineMedium: tune(base.headlineMedium),
      headlineSmall: tune(base.headlineSmall),
      titleLarge: tune(base.titleLarge),
      titleMedium: tune(base.titleMedium),
      titleSmall: tune(base.titleSmall),
      bodyLarge: tune(base.bodyLarge),
      bodyMedium: tune(base.bodyMedium),
      bodySmall: tune(base.bodySmall),
      labelLarge: tune(base.labelLarge),
      labelMedium: tune(base.labelMedium),
      labelSmall: tune(base.labelSmall),
    );
  }
}
