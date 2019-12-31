import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Platform charset converter.
///
/// Utilizes channels to use platform built-in charset converter.
/// This śaves app package size, but sacrifice on performance.
class PlatformCharsetConverter {
  static const MethodChannel _channel =
      const MethodChannel('platform_charset_conv');

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

  /// Get list of available charsets
  static Future<List<String>> availableCharsets() async {
    final List<dynamic> result =
        await _channel.invokeMethod('availableCharsets');
    return result.map((name) => name as String).toList();
  }
}
