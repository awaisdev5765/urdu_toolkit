/// Flutter widgets for Urdu text.
///
/// Separate from the main library so a backend or CLI tool can use the text
/// utilities without pulling in the framework.
///
/// ```dart
/// import 'package:urdu_toolkit/widgets.dart';
///
/// UrduText('آپ کا نام'),
/// ```
library;

export 'src/urdu_text.dart' show UrduText;
export 'src/nastaliq_theme.dart' show UrduTextTheme;
