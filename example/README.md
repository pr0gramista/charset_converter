# Platform charset converter example

Demonstrates how to use the charset_converter plugin.

The app is doing 3 things:
* Decodes Windows 1250 data, which is "Cześć" - hello in Polish
* Encodes Thai Hello to TIS620
* Checks if `i_should_not_be_available` encoding is available - probably not
* Checks if `EUC-KR` encoding is available - probably yes
* Displays list of available charsets

![Screenshot of the example on iOS](/example/screenshot-ios.png)
![Screenshot of the example on Android](/example/screenshot-android.png)