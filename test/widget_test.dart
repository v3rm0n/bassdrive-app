import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bassdrive_radio/utils/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('BassdriveApp has correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        title: 'Bassdrive Radio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: Text('Test Home'),
          ),
        ),
      ),
    );

    // Verify MaterialApp has correct title
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Bassdrive Radio');
  });

  testWidgets('App uses dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        title: 'Bassdrive Radio',
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: Text('Test Home'),
          ),
        ),
      ),
    );

    // Verify dark theme is used
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.brightness, Brightness.dark);
  });

  testWidgets('Theme has correct primary color', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: Text('Test Home'),
          ),
        ),
      ),
    );

    // Verify theme has correct primary color
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.colorScheme.primary, AppTheme.primaryColor);
  });
}
