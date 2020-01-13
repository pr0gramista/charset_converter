# Charset converter example

Demonstrates how to use the charset_converter plugin.

The app is doing 3 things:
* Decodes Windows 1250 data, which is "Cześć" - hello in Polish
* Encodes Thai Hello to TIS620
* Checks if `i_should_not_be_available` encoding is available - probably not
* Checks if `EUC-KR` encoding is available - probably yes
* Displays list of available charsets

![Screenshot of the example on iOS](https://github.com/pr0gramista/charset_converter/blob/master/example/screenshot-ios.png?raw=true)
![Screenshot of the example on Android](https://github.com/pr0gramista/charset_converter/blob/master/example/screenshot-android.png?raw=true)