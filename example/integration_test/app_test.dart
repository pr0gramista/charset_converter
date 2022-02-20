import 'package:charset_converter_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Charset converter', () {
    testWidgets('decodes CP1250', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.pumpAndSettle();

      final output = tester.widget<Text>(find.byKey(const Key("decoded")));

      expect(output.data, "Decoded from Windows CP1250: Cześć");
    });

    testWidgets('encodes TIS620', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.pumpAndSettle();

      final output = tester.widget<Text>(find.byKey(const Key("encoded")));

      expect(output.data, "Encoded to TIS620: 202, 199, 209, 202, 180, 213");
    });

    testWidgets('has available charsets', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key("available_charsets")),
          matching: find.byType(Text),
        ),
        findsWidgets,
      );
    });

    testWidgets('checks charset availability for i_should_not_be_available',
        (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.pumpAndSettle();

      final output = tester.widget<Text>(
          find.byKey(const Key("charset_i_should_not_be_available")));

      expect(output.data, "Is i_should_not_be_available available: false");
    });

    testWidgets('checks charset availability for EUC-KR', (tester) async {
      const charset = "EUC-KR";

      await tester.pumpWidget(const MyApp());

      await tester.pumpAndSettle();

      final output =
          tester.widget<Text>(find.byKey(const Key("charset_$charset")));

      expect(output.data, "Is $charset available: true");
    });
  });
}
