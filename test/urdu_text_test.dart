import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:urdu_toolkit/widgets.dart';

void main() {
  group('UrduText', () {
    testWidgets('renders Urdu text with RTL direction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UrduText('آپ کیسے ہیں؟'))),
      );

      final direction = Directionality.of(
        tester.element(find.byType(Text)),
      );
      expect(direction, TextDirection.rtl);
      expect(find.text('آپ کیسے ہیں؟'), findsOneWidget);
    });

    testWidgets('uses LTR for English text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UrduText('Hello world'))),
      );

      final direction = Directionality.of(
        tester.element(find.byType(Text)),
      );
      expect(direction, TextDirection.ltr);
    });

    testWidgets('mixed content is treated as RTL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UrduText('Hello، آپ کیسے ہیں؟')),
        ),
      );

      final direction = Directionality.of(
        tester.element(find.byType(Text)),
      );
      expect(direction, TextDirection.rtl);
    });

    testWidgets('forceRtl overrides content detection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
            home: Scaffold(body: UrduText('Hello', forceRtl: true))),
      );

      final direction = Directionality.of(
        tester.element(find.byType(Text)),
      );
      expect(direction, TextDirection.rtl);
    });

    testWidgets('normalises by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UrduText('كتاب'))),
      );

      // Arabic kaf is replaced with Urdu kaf.
      expect(find.text('کتاب'), findsOneWidget);
      expect(find.text('كتاب'), findsNothing);
    });

    testWidgets('normalisation can be disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UrduText('كتاب', normalise: false)),
        ),
      );

      expect(find.text('كتاب'), findsOneWidget);
    });

    testWidgets('applies the Nastaliq family when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UrduText(
              'آپ',
              nastaliqFontFamily: 'NotoNastaliqUrdu',
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontFamilyFallback?.first, 'NotoNastaliqUrdu');
    });

    testWidgets('no font fallback when no Nastaliq family is given',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UrduText('آپ'))),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontFamilyFallback, isNull);
    });

    testWidgets('isRtl reflects the direction the widget will use',
        (tester) async {
      const widget = UrduText('آپ کیسے ہیں؟');
      expect(widget.isRtl, isTrue);

      const english = UrduText('Hello');
      expect(english.isRtl, isFalse);
    });
  });
}
