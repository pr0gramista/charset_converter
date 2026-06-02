import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

// CFStringEncoding sentinel returned when an IANA name is unknown.
const int _kCFStringEncodingInvalidId = 0xffffffff;
const int _kCFStringEncodingUTF8 = 0x08000100;

typedef _CFStringCreateWithBytesNative =
    Pointer<Void> Function(
      Pointer<Void> alloc,
      Pointer<Uint8> bytes,
      IntPtr numBytes,
      Uint32 encoding,
      Uint8 isExternalRepresentation,
    );
typedef _CFStringCreateWithBytesDart =
    Pointer<Void> Function(
      Pointer<Void> alloc,
      Pointer<Uint8> bytes,
      int numBytes,
      int encoding,
      int isExternalRepresentation,
    );

typedef _CFStringConvertIANACharSetNameToEncodingNative =
    Uint32 Function(Pointer<Void> theString);
typedef _CFStringConvertIANACharSetNameToEncodingDart =
    int Function(Pointer<Void> theString);

typedef _CFStringConvertEncodingToIANACharSetNameNative =
    Pointer<Void> Function(Uint32 encoding);
typedef _CFStringConvertEncodingToIANACharSetNameDart =
    Pointer<Void> Function(int encoding);

typedef _CFStringGetLengthNative = IntPtr Function(Pointer<Void> theString);
typedef _CFStringGetLengthDart = int Function(Pointer<Void> theString);

final class _CFRange extends Struct {
  @IntPtr()
  external int location;
  @IntPtr()
  external int length;
}

typedef _CFStringGetBytesNative =
    IntPtr Function(
      Pointer<Void> theString,
      _CFRange range,
      Uint32 encoding,
      Uint8 lossByte,
      Uint8 isExternalRepresentation,
      Pointer<Uint8> buffer,
      IntPtr maxBufLen,
      Pointer<IntPtr> usedBufLen,
    );
typedef _CFStringGetBytesDart =
    int Function(
      Pointer<Void> theString,
      _CFRange range,
      int encoding,
      int lossByte,
      int isExternalRepresentation,
      Pointer<Uint8> buffer,
      int maxBufLen,
      Pointer<IntPtr> usedBufLen,
    );

typedef _CFReleaseNative = Void Function(Pointer<Void> cf);
typedef _CFReleaseDart = void Function(Pointer<Void> cf);

typedef _CFStringGetListOfAvailableEncodingsNative =
    Pointer<Uint32> Function();
typedef _CFStringGetListOfAvailableEncodingsDart =
    Pointer<Uint32> Function();

class _CoreFoundation {
  _CoreFoundation._() {
    final lib = DynamicLibrary.process();
    cfStringCreateWithBytes = lib
        .lookupFunction<
          _CFStringCreateWithBytesNative,
          _CFStringCreateWithBytesDart
        >('CFStringCreateWithBytes');
    cfStringConvertIANACharSetNameToEncoding = lib
        .lookupFunction<
          _CFStringConvertIANACharSetNameToEncodingNative,
          _CFStringConvertIANACharSetNameToEncodingDart
        >('CFStringConvertIANACharSetNameToEncoding');
    cfStringConvertEncodingToIANACharSetName = lib
        .lookupFunction<
          _CFStringConvertEncodingToIANACharSetNameNative,
          _CFStringConvertEncodingToIANACharSetNameDart
        >('CFStringConvertEncodingToIANACharSetName');
    cfStringGetLength = lib
        .lookupFunction<_CFStringGetLengthNative, _CFStringGetLengthDart>(
          'CFStringGetLength',
        );
    cfStringGetBytes = lib
        .lookupFunction<_CFStringGetBytesNative, _CFStringGetBytesDart>(
          'CFStringGetBytes',
        );
    cfRelease = lib.lookupFunction<_CFReleaseNative, _CFReleaseDart>(
      'CFRelease',
    );
    cfStringGetListOfAvailableEncodings = lib
        .lookupFunction<
          _CFStringGetListOfAvailableEncodingsNative,
          _CFStringGetListOfAvailableEncodingsDart
        >('CFStringGetListOfAvailableEncodings');
  }

  static final _CoreFoundation instance = _CoreFoundation._();

  late final _CFStringCreateWithBytesDart cfStringCreateWithBytes;
  late final _CFStringConvertIANACharSetNameToEncodingDart
  cfStringConvertIANACharSetNameToEncoding;
  late final _CFStringConvertEncodingToIANACharSetNameDart
  cfStringConvertEncodingToIANACharSetName;
  late final _CFStringGetLengthDart cfStringGetLength;
  late final _CFStringGetBytesDart cfStringGetBytes;
  late final _CFReleaseDart cfRelease;
  late final _CFStringGetListOfAvailableEncodingsDart
  cfStringGetListOfAvailableEncodings;
}

int _lookupEncoding(String charset) {
  final cf = _CoreFoundation.instance;
  final nameBytes = ascii.encode(charset);
  final ptr = calloc<Uint8>(nameBytes.length);
  try {
    ptr.asTypedList(nameBytes.length).setAll(0, nameBytes);
    final cfName = cf.cfStringCreateWithBytes(
      nullptr,
      ptr,
      nameBytes.length,
      _kCFStringEncodingUTF8,
      0,
    );
    if (cfName == nullptr) return _kCFStringEncodingInvalidId;
    try {
      return cf.cfStringConvertIANACharSetNameToEncoding(cfName);
    } finally {
      cf.cfRelease(cfName);
    }
  } finally {
    calloc.free(ptr);
  }
}

Uint8List? appleEncode(String charset, String data) {
  final cf = _CoreFoundation.instance;
  final encoding = _lookupEncoding(charset);
  if (encoding == _kCFStringEncodingInvalidId) return null;

  final utf8Bytes = utf8.encode(data);
  final utf8Ptr = calloc<Uint8>(utf8Bytes.length);
  try {
    utf8Ptr.asTypedList(utf8Bytes.length).setAll(0, utf8Bytes);
    final cfStr = cf.cfStringCreateWithBytes(
      nullptr,
      utf8Ptr,
      utf8Bytes.length,
      _kCFStringEncodingUTF8,
      0,
    );
    if (cfStr == nullptr) {
      throw _AppleEncodingFailed();
    }
    try {
      final length = cf.cfStringGetLength(cfStr);
      final range = calloc<_CFRange>();
      final usedLen = calloc<IntPtr>();
      try {
        range.ref.location = 0;
        range.ref.length = length;
        cf.cfStringGetBytes(
          cfStr,
          range.ref,
          encoding,
          0,
          0,
          nullptr,
          0,
          usedLen,
        );
        final size = usedLen.value;
        if (size <= 0) {
          throw _AppleEncodingFailed();
        }
        final out = calloc<Uint8>(size);
        try {
          final converted = cf.cfStringGetBytes(
            cfStr,
            range.ref,
            encoding,
            0,
            0,
            out,
            size,
            usedLen,
          );
          if (converted == 0) {
            throw _AppleEncodingFailed();
          }
          return Uint8List.fromList(out.asTypedList(usedLen.value));
        } finally {
          calloc.free(out);
        }
      } finally {
        calloc.free(range);
        calloc.free(usedLen);
      }
    } finally {
      cf.cfRelease(cfStr);
    }
  } finally {
    calloc.free(utf8Ptr);
  }
}

String? appleDecode(String charset, Uint8List data) {
  final cf = _CoreFoundation.instance;
  final encoding = _lookupEncoding(charset);
  if (encoding == _kCFStringEncodingInvalidId) return null;

  final inPtr = calloc<Uint8>(data.length);
  try {
    inPtr.asTypedList(data.length).setAll(0, data);
    final cfStr = cf.cfStringCreateWithBytes(
      nullptr,
      inPtr,
      data.length,
      encoding,
      0,
    );
    if (cfStr == nullptr) return null;
    try {
      final length = cf.cfStringGetLength(cfStr);
      final range = calloc<_CFRange>();
      final usedLen = calloc<IntPtr>();
      try {
        range.ref.location = 0;
        range.ref.length = length;
        cf.cfStringGetBytes(
          cfStr,
          range.ref,
          _kCFStringEncodingUTF8,
          0,
          0,
          nullptr,
          0,
          usedLen,
        );
        final size = usedLen.value;
        if (size <= 0) return '';
        final out = calloc<Uint8>(size);
        try {
          cf.cfStringGetBytes(
            cfStr,
            range.ref,
            _kCFStringEncodingUTF8,
            0,
            0,
            out,
            size,
            usedLen,
          );
          return utf8.decode(out.asTypedList(usedLen.value));
        } finally {
          calloc.free(out);
        }
      } finally {
        calloc.free(range);
        calloc.free(usedLen);
      }
    } finally {
      cf.cfRelease(cfStr);
    }
  } finally {
    calloc.free(inPtr);
  }
}

bool appleCheckAvailability(String charset) {
  return _lookupEncoding(charset) != _kCFStringEncodingInvalidId;
}

List<String> appleAvailableCharsets() {
  final cf = _CoreFoundation.instance;
  final list = cf.cfStringGetListOfAvailableEncodings();
  if (list == nullptr) return const [];
  final result = <String>[];
  var i = 0;
  while (true) {
    final enc = list.elementAt(i).value;
    if (enc == _kCFStringEncodingInvalidId) break;
    final cfName = cf.cfStringConvertEncodingToIANACharSetName(enc);
    if (cfName != nullptr) {
      final length = cf.cfStringGetLength(cfName);
      if (length > 0) {
        final range = calloc<_CFRange>();
        final usedLen = calloc<IntPtr>();
        try {
          range.ref.location = 0;
          range.ref.length = length;
          cf.cfStringGetBytes(
            cfName,
            range.ref,
            _kCFStringEncodingUTF8,
            0,
            0,
            nullptr,
            0,
            usedLen,
          );
          final size = usedLen.value;
          if (size > 0) {
            final out = calloc<Uint8>(size);
            try {
              cf.cfStringGetBytes(
                cfName,
                range.ref,
                _kCFStringEncodingUTF8,
                0,
                0,
                out,
                size,
                usedLen,
              );
              result.add(utf8.decode(out.asTypedList(usedLen.value)));
            } finally {
              calloc.free(out);
            }
          }
        } finally {
          calloc.free(range);
          calloc.free(usedLen);
        }
      }
      // CFStringConvertEncodingToIANACharSetName returns a non-owned reference.
    }
    i++;
  }
  return result;
}

class _AppleEncodingFailed implements Exception {}
