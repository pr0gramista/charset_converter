import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:charset_converter/charset_converter.dart';

void main() {
  const MethodChannel channel = MethodChannel('charset_converter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == "encode") {
        if (Platform.isLinux) {
          return (methodCall.arguments["data"] as Uint8List).sublist(
              0, (methodCall.arguments["data"] as Uint8List).length - 1);
        }
        return Uint8List.fromList(
            (methodCall.arguments["data"] as String).codeUnits);
      } else if (methodCall.method == "decode") {
        if (Platform.isLinux) {
          return String.fromCharCodes(
              (methodCall.arguments["data"] as Uint8List).sublist(
                  0, (methodCall.arguments["data"] as Uint8List).length - 1));
        }
        return String.fromCharCodes(methodCall.arguments["data"]);
      } else if (methodCall.method == "availableCharsets") {
        return ["windows1250", "Big5", "GBK"];
      } else if (methodCall.method == "check") {
        return methodCall.arguments["charset"] == "utf8";
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('Encode', () async {
    expect(await CharsetConverter.encode("utf8", "abc"), [97, 98, 99]);
  });

  test('Decode', () async {
    expect(
        await CharsetConverter.decode("utf8", Uint8List.fromList([97, 98, 99])),
        "abc");
  });

  test('Get available charsets', () async {
    expect(await CharsetConverter.availableCharsets(),
        ["windows1250", "Big5", "GBK"]);
  });

  test('Charset availability check', () async {
    expect(await CharsetConverter.checkAvailability("utf8"), true);
    expect(
        await CharsetConverter.checkAvailability("i_should_not_be_available"),
        false);
  });
}
