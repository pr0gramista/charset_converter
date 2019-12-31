# Platform charset converter
Encode and decode charsets using platform built-in converter. This saves app package size as you don't need any external charset maps or whole libraries like iconv. However this comes with the dependency on the platform.

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

## Internals
Android comes 

## Contributions
