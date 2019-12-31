# Platform charset converter
Encode and decode charsets using platform built-in converter. This saves app package size as you don't need any external charset maps or whole libraries like iconv. However this comes with the dependency on the platform.

Still package was originally made to help deal with [this StackOverflow question](https://stackoverflow.com/questions/59475607/how-to-print-asian-languages-to-a-thermal-printer-from-flutter/59531422#59531422).

## Usage
#### Encoding
```dart
Uint8List encoded = await PlatformCharsetConverter.encode("windows1250", "Polish has óśćł");
```

#### Decoding
```dart
String decoded = await PlatformCharsetConverter.decode("windows1250",
    Uint8List.fromList([0x43, 0x7A, 0x65, 0x9C, 0xE6])); // Hello (Cześć) in Polish
```

#### Getting list of available charsets
Helpful if you don't know exact name of the charset.

```dart
List<String> charsets = await PlatformCharsetConverter.availableCharsets();
```

## What's coming
- iOS support
- Stream API

## How does it work?
Android comes with Java runtime, which has a built-in [Charset](https://docs.oracle.com/javase/7/docs/api/java/nio/charset/Charset.html) class which has convenient `encode` and `decode` methods. All it's left to do is use channels to pass the data.

## Contributing
Feel free to create issues, fix bugs, add new functionalities even if you are not sure about. Everyone is welcome!
