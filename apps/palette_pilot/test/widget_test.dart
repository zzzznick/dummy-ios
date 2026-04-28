// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:palette_pilot/app/settings/app_settings_controller.dart';
import 'package:palette_pilot/app/settings/app_settings_store.dart';
import 'package:palette_pilot/_vsbwk/_vsbwk.dart';

void main() {
  testWidgets('Boot UI renders', (WidgetTester tester) async {
    final settings = AppSettingsController(AppSettingsStore());

    await tester.pumpWidget(
      MaterialApp(
        home: Vsbwk0(a: (_) => const SizedBox.shrink(), b: false),
      ),
    );

    expect(find.text('Preparing your workspace'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
