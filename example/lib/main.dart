import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/services.dart';
import 'package:super_form/super_form.dart';

void main() => runApp(const MyApp());

const gap = SizedBox(
  width: 8,
  height: 8,
);

const horizontalPadding = EdgeInsets.symmetric(horizontal: 8);

enum ConversionMode { encode, decode, checkAvailability }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? output;
  bool isLoading = false;
  ConversionMode mode = ConversionMode.encode;

  Uint8List _parseByteList(String input) {
    final parts = input.split(',');
    final parsedBytes = parts.map((e) => int.tryParse(e)).toList();

    if (parsedBytes.contains(null)) {
      throw FormatException("Could not parse $input as list of bytes");
    }

    return Uint8List.fromList(parsedBytes.cast<int>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CharsetConverter example'),
        ),
        body: Builder(builder: (context) {
          return SuperForm(
            onSubmit: (values) async {
              final String? input = values["input"];
              final String charset = values["charset"];

              setState(() {
                output = null;
                isLoading = true;
              });

              try {
                if (mode == ConversionMode.encode) {
                  final result = await CharsetConverter.encode(charset, input!);

                  setState(() {
                    output = result.join(', ');
                  });
                } else if (mode == ConversionMode.decode) {
                  final result = await CharsetConverter.decode(
                      charset, _parseByteList(input!));

                  setState(() {
                    output = result;
                  });
                } else if (mode == ConversionMode.checkAvailability) {
                  final result =
                      await CharsetConverter.checkAvailability(charset);

                  setState(() {
                    output = result ? "Available" : "Not found";
                  });
                } else {
                  throw UnimplementedError("Unknown conversion mode");
                }
              } on PlatformException catch (e) {
                log(e.toString());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Something went wrong"),
                  ),
                );
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
            },
            child: ListView(
              children: [
                gap,
                gap,
                Padding(
                  padding: horizontalPadding,
                  child: TextSuperFormField(
                    name: "input",
                    rules: [
                      CustomRule((input) {
                        if (mode == ConversionMode.encode ||
                            mode == ConversionMode.decode) {
                          if (input == null || (input as String?)!.isEmpty) {
                            return "Cannot be empty";
                          }
                        }

                        if (mode == ConversionMode.decode) {
                          try {
                            _parseByteList(input);
                          } on FormatException catch (_) {
                            return "Must be in format of comma-separated bytes";
                          }
                        }
                        return null;
                      })
                    ],
                    decoration: const InputDecoration(
                      label: Text("Input"),
                      hintText: "Text or list of bytes like 65, 66, 67",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                gap,
                gap,
                Padding(
                  padding: horizontalPadding,
                  child: TextSuperFormField(
                    name: "charset",
                    rules: [
                      RequiredRule("Cannot be empty"),
                    ],
                    decoration: const InputDecoration(
                      label: Text("Charset"),
                      hintText: "Charset name like windows1250",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                gap,
                Builder(builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            mode = ConversionMode.encode;

                            SuperForm.of(context, listen: false).submit();
                          },
                          child: const Text("Encode"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            mode = ConversionMode.decode;

                            SuperForm.of(context, listen: false).submit();
                          },
                          child: const Text("Decode"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            mode = ConversionMode.checkAvailability;

                            SuperForm.of(context, listen: false).submit();
                          },
                          child: const Text("Check if available"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              output = null;
                              isLoading = true;
                            });

                            final charsets =
                                await CharsetConverter.availableCharsets();

                            setState(() {
                              output = charsets.join("\n");
                              isLoading = false;
                            });
                          },
                          child: const Text("Get available charsets"),
                        )
                      ],
                    ),
                  );
                }),
                gap,
                if (isLoading)
                  const Padding(
                    padding: horizontalPadding,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (output != null)
                  Padding(
                    padding: horizontalPadding,
                    child: SelectableText(
                      output!,
                      key: const Key("output"),
                    ),
                  ),
                gap,
                gap,
              ],
            ),
          );
        }),
      ),
    );
  }
}
