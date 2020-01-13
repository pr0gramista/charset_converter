import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Charset converter.
///
/// Utilizes channels to use platform built-in charset converter.
/// Helps with Dart's lack of many charset codecs.
/// This saves app package size, however does come with platform dependency.
///
/// This package does not include any external dependcies.
class CharsetConverter {
  static const MethodChannel _channel =
      const MethodChannel('charset_converter');

  /// Encodes [data] to given [charset] supported by the platform
  static Future<Uint8List> encode(String charset, String data) async {
    assert(charset != null);
    assert(data != null);

    return await _channel.invokeMethod('encode', {
      "charset": charset,
      "data": data,
    });
  }

  /// Decodes [data] into [String] by given [charset]
  static Future<String> decode(String charset, Uint8List data) async {
    assert(charset != null);
    assert(data != null);

    return await _channel.invokeMethod('decode', {
      "charset": charset,
      "data": data,
    });
  }

  /// Check if given [charset] is available
  static Future<bool> checkAvailability(String charset) async {
    assert(charset != null);

    return await _channel.invokeMethod('check', {"charset": charset});
  }

  /// Get list of available charsets
  static Future<List<String>> availableCharsets() async {
    final List<dynamic> result =
        await _channel.invokeMethod('availableCharsets');
    return result.map((name) => name as String).toList();
  }
}
