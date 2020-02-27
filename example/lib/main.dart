import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:charset_converter/charset_converter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _decoded;
  Uint8List _encoded;
  bool _errored = false;

  @override
  void initState() {
    super.initState();
    decodeAndEncode();
  }

  Future<void> decodeAndEncode() async {
    String decoded;
    Uint8List encoded;

    try {
      encoded =
          await CharsetConverter.encode("TIS620", "สวัสดี"); // Hello in Thai
      decoded = await CharsetConverter.decode(
          "windows1250",
          Uint8List.fromList(
              [0x43, 0x7A, 0x65, 0x9C, 0xE6])); // Hello in Polish
    } on PlatformException {
      setState(() {
        _errored = true;
      });
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _decoded = decoded;
      _encoded = encoded;
    });
  }

  /// Generates widget builder for [FutureBuilder] for given [charset]
  Function _charsetAvailabilityView(String charset) {
    return (context, snapshot) {
      if (snapshot.hasData) {
        bool isAvailable = snapshot.data as bool;

        return Text("Is $charset available: " + isAvailable.toString(),
            key: Key('charset_$charset'));
      }
      return CircularProgressIndicator();
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CharsetConverter example'),
        ),
        body: Center(
            child: Column(children: [
          if (_decoded != null)
            Text("Decoded from Windows CP1250: " + _decoded,
                key: Key('decoded')),
          if (_encoded != null)
            Text("Encoded to TIS620: " + _encoded.join(", "),
                key: Key('encoded')),
          if (_errored) Text("Something went wrong :C"),
          FutureBuilder(
              future: CharsetConverter.checkAvailability(
                  "i_should_not_be_available"),
              builder: _charsetAvailabilityView("i_should_not_be_available")),
          FutureBuilder(
              future: CharsetConverter.checkAvailability("EUC-KR"),
              builder: _charsetAvailabilityView("EUC-KR")),
          Expanded(
              child: FutureBuilder(
            future: CharsetConverter.availableCharsets(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final charsets = snapshot.data as List<String>;

                return ListView.builder(
                    itemCount: charsets.length,
                    itemBuilder: (context, index) => Text(charsets[index]));
              }
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return CircularProgressIndicator();
            },
          )),
        ])),
      ),
    );
  }
}
