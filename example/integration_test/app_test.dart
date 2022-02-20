import 'package:charset_converter_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

class ConversionTestCase {
  final String charset;
  final String utf16;
  final String bytes;

  ConversionTestCase(this.charset, this.utf16, this.bytes);
}

final charsetTestCases = [
  ConversionTestCase("TIS620", "สวัสดี", "202, 199, 209, 202, 180, 213"),
  ConversionTestCase("Big5", "中文abc", "164, 164, 164, 229, 97, 98, 99"),
  ConversionTestCase("Big5", "測試", "180, 250, 184, 213"),
  ConversionTestCase("EUC-KR", "김치", "177, 232, 196, 161"),
  ConversionTestCase("windows1250", "Cześć", "67, 122, 101, 156, 230"),
  ConversionTestCase("ISO-8859-7", "αβγδε", "225, 226, 227, 228, 229")
];

void main() {
  final Finder charsetField = find.byWidgetPredicate(
      (widget) => widget is TextSuperFormField && widget.name == "charset");
  final Finder inputField = find.byWidgetPredicate(
      (widget) => widget is TextSuperFormField && widget.name == "input");
  final Finder output = find.byKey(const Key("output"));

  group('Charset converter', () {
    for (final testCase in charsetTestCases) {
      testWidgets("encodes ${testCase.utf16} in ${testCase.charset}",
          (tester) async {
        await tester.pumpWidget(const MyApp());

        await tester.enterText(charsetField, testCase.charset);
        await tester.enterText(inputField, testCase.utf16);
        await tester.pumpAndSettle();

        await tester.tap(find.text("Encode"));
        await tester.pumpAndSettle();

        expect(tester.widget<SelectableText>(output).data!, testCase.bytes);
      });

      testWidgets("decodes ${testCase.bytes} in ${testCase.charset}",
          (tester) async {
        await tester.pumpWidget(const MyApp());

        await tester.enterText(charsetField, testCase.charset);
        await tester.enterText(inputField, testCase.bytes);
        await tester.pumpAndSettle();

        await tester.tap(find.text("Decode"));
        await tester.pumpAndSettle();

        expect(tester.widget<SelectableText>(output).data!, testCase.utf16);
      });

      testWidgets("checks ${testCase.charset} is available", (tester) async {
        await tester.pumpWidget(const MyApp());

        await tester.enterText(charsetField, testCase.charset);
        await tester.pumpAndSettle();

        await tester.tap(find.text("Check if available"));
        await tester.pumpAndSettle();

        expect(tester.widget<SelectableText>(output).data!, "Available");
      });
    }

    testWidgets("has available charsets", (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text("Get available charsets"));
      await tester.pumpAndSettle();

      expect(
          tester.widget<SelectableText>(output).data!.length, greaterThan(100));
    });

    testWidgets('checks i_should_not_be_available is not available',
        (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.enterText(charsetField, "i_should_not_be_available");
      await tester.pumpAndSettle();

      await tester.tap(find.text("Check if available"));
      await tester.pumpAndSettle();

      expect(tester.widget<SelectableText>(output).data!, "Not found");
    });
  });
}
