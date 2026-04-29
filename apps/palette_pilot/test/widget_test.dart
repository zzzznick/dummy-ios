// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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

  testWidgets('Routes to type-1 shell when configured', (WidgetTester tester) async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeAdapter(
      body:
          '[{"vsbwkPlaf":"1","vsbwkUr":"https://example.com"}]',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Vsbwk0(
          a: (_) => const SizedBox.shrink(),
          c: (_, __) => const Scaffold(body: Text('S1')),
          f: dio,
          g: Duration.zero,
        ),
      ),
    );

    await tester.pump(); // post-frame callback
    await tester.pump(); // async microtasks
    await tester.pumpAndSettle();

    expect(find.text('S1'), findsOneWidget);
  });

  test('Generated shell has no visible title strings', () {
    final src = File('lib/_vsbwk/_vsbwk.dart').readAsStringSync();
    expect(src.contains('Workspace'), isFalse);
    expect(src.contains('Browse'), isFalse);
  });

  test('Generated shell uses container black frame only', () {
    final src = File('lib/_vsbwk/_vsbwk.dart').readAsStringSync();
    expect(src.contains('SystemChrome'), isFalse);
    expect(src.contains('SystemUiOverlayStyle'), isFalse);
    expect(src.contains('Colors.black'), isTrue);
    expect(src.contains('SafeArea('), isTrue);
  });
}

class _FakeAdapter extends IOHttpClientAdapter {
  _FakeAdapter({required this.body});

  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
