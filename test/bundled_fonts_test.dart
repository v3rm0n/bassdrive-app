import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every family and weight the theme uses must ship as an asset, or the app
/// falls back to the platform font when it starts without a connection.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fonts used by the theme are bundled as assets', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().toSet();

    const expected = [
      'BigShoulders-Bold',
      'BigShoulders-ExtraBold',
      'BigShoulders-Black',
      'InstrumentSans-Regular',
      'InstrumentSans-Medium',
      'InstrumentSans-SemiBold',
      'InstrumentSans-Bold',
    ];
    for (final name in expected) {
      expect(assets, contains('assets/google_fonts/$name.ttf'));
    }
  });
}
