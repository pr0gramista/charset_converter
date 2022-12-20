import 'dart:async';

import 'package:flutter/services.dart';

/// Charset converter.
///
/// Utilizes channels to use platform built-in charset converter.
/// Helps with Dart's lack of many charset codecs.
/// This saves app package size, however does come with platform dependency.
///
/// This package does not include any external dependcies.
class CharsetConverter {
  static const MethodChannel _channel = MethodChannel('charset_converter');

  /// Encodes [data] to given [charset] supported by the platform.
  ///
  /// When encoding fails either [CharsetConversionError] or [PlatformException] is thrown.
  static Future<Uint8List> encode(String charset, String data) async {
    final result = await _channel.invokeMethod('encode', {
      "charset": charset,
      "data": data,
    });

    if (result == null) {
      throw CharsetConversionError(
        "Result of encoding was null which may indicate that native converter failed to encode your data",
        true,
      );
    }

    return result;
  }

  /// Decodes [data] into [String] by given [charset].
  ///
  /// When decoding fails either [CharsetConversionError] or [PlatformException] is thrown.
  static Future<String> decode(String charset, Uint8List data) async {
    final result = await _channel.invokeMethod('decode', {
      "charset": charset,
      "data": data,
    });

    if (result == null) {
      throw CharsetConversionError(
        "Result of decoding was null which may indicate that native converter failed to decode your data",
        false,
      );
    }

    return result;
  }

  /// Check if given [charset] is available
  static Future<bool> checkAvailability(String charset) async {
    final result = await _channel.invokeMethod('check', {"charset": charset});

    if (result == null) return false;

    return result;
  }

  /// Get list of available charsets
  static Future<List<String>> availableCharsets() async {
    final List<dynamic>? result =
        await _channel.invokeMethod('availableCharsets');

    if (result == null) return [];

    return result.map((name) => name as String).toList();
  }
}

class CharsetConversionError extends Error {
  final String message;
  final bool encoding;

  CharsetConversionError(this.message, this.encoding);

  bool get decoding => !encoding;

  @override
  String toString() {
    return "CharsetConversionError: $message";
  }
}
