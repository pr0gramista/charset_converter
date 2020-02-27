import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Charset converter', () {
    FlutterDriver driver;
    final timeout = Duration(milliseconds: 200);

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('decodes CP1250', () async {
      final finder = find.byValueKey('decoded');

      await driver.waitFor(finder, timeout: timeout);
      expect(
          await driver.getText(finder), "Decoded from Windows CP1250: Cześć");
    });

    test('encodes TIS620', () async {
      final finder = find.byValueKey('encoded');

      await driver.waitFor(finder, timeout: timeout);
      expect(await driver.getText(finder),
          "Encoded to TIS620: 202, 199, 209, 202, 180, 213");
    });

    test('charset availability for i_should_not_be_available', () async {
      final charset = 'i_should_not_be_available';
      final finder = find.byValueKey('charset_$charset');

      await driver.waitFor(finder, timeout: timeout);
      expect(await driver.getText(finder), "Is $charset available: false");
    });

    test('charset availability for EUC-KR', () async {
      final charset = 'EUC-KR';
      final finder = find.byValueKey('charset_$charset');

      await driver.waitFor(finder, timeout: timeout);
      expect(await driver.getText(finder), "Is $charset available: true");
    });
  });
}
