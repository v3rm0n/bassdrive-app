import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Bassdrive App', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('take screenshot', () async {
      await driver.waitUntilFirstFrameRasterized();
      final screenshot = await driver.screenshot();
      // Save screenshot to file
      // final file = File('screenshot.png');
      // await file.writeAsBytes(screenshot);
    });
  });
}
