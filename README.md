# Charset converter
[![pub package](https://img.shields.io/pub/v/charset_converter.svg)](https://pub.dartlang.org/packages/charset_converter)
[![Tests status](https://github.com/pr0gramista/charset_converter/workflows/Tests/badge.svg)](https://github.com/pr0gramista/charset_converter/actions)
![Integration test status](https://api.codemagic.io/apps/6212498f0b28f648d6d103b4/tests-mobile/status_badge.svg)

Encode and decode charsets using platform built-in converter. This saves app package size as you don't need any external charset maps or whole libraries like iconv. This package doesn't even contain any Dart dependencies. However this comes with the dependency on the platform.

This package was originally made to help deal with [this StackOverflow question](https://stackoverflow.com/questions/59475607/how-to-print-asian-languages-to-a-thermal-printer-from-flutter/59531422#59531422) and [Dart](https://api.dartlang.org/stable/2.7.0/dart-convert/dart-convert-library.html)'s lack of support for many specific charset like GBK, Big5, Windows-125X or ISO-8859-XX.

## Usage
Checkout these snippets or [full example](https://github.com/pr0gramista/charset_converter/tree/master/example).

#### Encoding
```dart
Uint8List encoded = await CharsetConverter.encode("windows1250", "Polish has óśćł");
```

#### Decoding
```dart
String decoded = await CharsetConverter.decode("windows1250",
    Uint8List.fromList([0x43, 0x7A, 0x65, 0x9C, 0xE6])); // Hello (Cześć) in Polish
```

#### Getting list of available charsets
Helpful if you don't know exact name of the charset.

```dart
List<String> charsets = await CharsetConverter.availableCharsets();
```

**Warning:** Please note that even if charset is not present on the list, it still might work. This is because the function is not returning the full list of aliases, this is presented in the example of iOS - TIS620 does not appear on the list, but ISO 8859-11, which is actually an alias of TIS620 does. To check if charset is available use `CharsetConverter.checkAvailability`.

Please also note that names are platform specific and may be different.

#### Checking availability of charset
```dart
bool isAvailable = await CharsetConverter.checkAvailability("EUC-KR");
```

## Preview of what encoding you may find
This can be helpful if you are not sure what you are looking for.
* [Android](https://github.com/pr0gramista/charset_converter/blob/master/CHARSETS-ANDROID)
* [iOS](https://github.com/pr0gramista/charset_converter/blob/master/CHARSETS-IOS)
* [Windows](https://github.com/pr0gramista/charset_converter/blob/master/CHARSETS-WINDOWS)

## How does it work?
Android comes with Java runtime, which has a built-in [Charset](https://docs.oracle.com/javase/7/docs/api/java/nio/charset/Charset.html) class which has convenient `encode` and `decode` methods. All it's left to do is use channels to pass the data.

iOS can also work with charsets with CoreFoundation CFString functions fe. `CFStringConvertIANACharSetNameToEncoding`. We can also easily encode and decode Strings with `init` and `data`. It is a little bit cumbersome since we have to convert the values and use ported C API.

Windows can use [MultiByteToWideChar](https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar) and [WideCharToMultiByte](https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-widechartomultibyte) from Win32.

## Contributing
Feel free to create issues, fix bugs, add new functionalities even if you are not sure about. Everyone is welcome!

## See also
- [flutter_charset_detector](https://pub.dev/packages/flutter_charset_detector) for detecting text encoding
