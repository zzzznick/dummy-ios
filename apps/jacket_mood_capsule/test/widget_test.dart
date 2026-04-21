// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:jacket_mood_capsule/app/settings/app_settings_controller.dart';
import 'package:jacket_mood_capsule/features/mood/pages/mood_home_page.dart';

void main() {
  testWidgets('MoodHomePage renders (no network)', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final settings = AppSettingsController();
    await settings.load();

    await tester.pumpWidget(
      MaterialApp(
        home: MoodHomePage(settings: settings),
      ),
    );
    await tester.pump();

    expect(find.text('Mood Capsule'), findsOneWidget);
  });
}
