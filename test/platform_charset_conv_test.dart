import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_charset_conv/platform_charset_conv.dart';

void main() {
  const MethodChannel channel = MethodChannel('platform_charset_conv');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == "encode") {
        return Uint8List.fromList(
            (methodCall.arguments["data"] as String).codeUnits);
      } else if (methodCall.method == "decode") {
        return String.fromCharCodes(methodCall.arguments["data"]);
      } else if (methodCall.method == "availableCharsets") {
        return ["windows1250", "Big5", "GBK"] as List<dynamic>;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('Encode', () async {
    expect(await PlatformCharsetConverter.encode("utf8", "abc"), [97, 98, 99]);
  });

  test('Decode', () async {
    expect(
        await PlatformCharsetConverter.decode(
            "utf8", Uint8List.fromList([97, 98, 99])),
        "abc");
  });

  test('Get available charsets', () async {
    expect(await PlatformCharsetConverter.availableCharsets(),
        ["windows1250", "Big5", "GBK"]);
  });
}
