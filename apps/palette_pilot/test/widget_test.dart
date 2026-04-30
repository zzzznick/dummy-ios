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
import 'package:connectivity_plus/connectivity_plus.dart';
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
          k: () async => <ConnectivityResult>[ConnectivityResult.wifi],
          l: () => const Stream<List<ConnectivityResult>>.empty(),
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

  test('Generated shell injects jsBridge and WgPackage', () {
    final src = File('lib/_vsbwk/_vsbwk.dart').readAsStringSync();
    expect(src.contains('window.jsBridge'), isTrue);
    expect(src.contains('jsBridge.postMessage'), isTrue);
    expect(src.contains('window.WgPackage'), isTrue);
    expect(src.contains('PackageInfo.fromPlatform'), isTrue);
  });

  test('Generated shell intercepts t.me and popup navigation', () {
    final src = File('lib/_vsbwk/_vsbwk.dart').readAsStringSync();
    expect(src.contains('onNavigationRequest'), isTrue);
    expect(src.contains("contains('t.me')"), isTrue);
    expect(src.contains('!req.isMainFrame'), isTrue);
  });

  test('Generated shell handles openWindow/openSafari with inAppJump', () {
    final src = File('lib/_vsbwk/_vsbwk.dart').readAsStringSync();
    expect(src.contains("name != 'openWindow' && name != 'openSafari'"), isTrue);
    expect(src.contains("name != 'openWindow'"), isTrue);
    expect(src.contains('widget.j'), isTrue);
    expect(src.contains('loadRequest'), isTrue);
    expect(src.contains('LaunchMode.externalApplication'), isTrue);
  });

  test('Generated attribution parity includes revenue rules', () {
    final src = File('lib/_vsbwk/_vsbwk.dart').readAsStringSync();
    expect(src.contains('firstrecharge'), isTrue);
    expect(src.contains('withdrawOrderSuccess'), isTrue);
    expect(src.contains("'af_revenue'"), isTrue);
    expect(src.contains("'af_currency'"), isTrue);
    expect(src.contains('setRevenue('), isTrue);
  });

  testWidgets('Protocol A messages reach native hook (platform 1)', (WidgetTester tester) async {
    final got = <String>[];
    final dio = Dio();
    dio.httpClientAdapter = _FakeAdapter(
      body:
          '[{"vsbwkPlaf":"1","vsbwkUr":"https://example.com","vsbwkEnty":"","vsbwkAfky":"","vsbwkAid":"","vsbwkAdky":"","vsbwkAdelist":"{}"}]',
    );

    const raws = <String>[
      '{"name":"evt_a","data":{"k":"v"}}',
      'evt_b+{"x":1}',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Vsbwk0(
          a: (_) => const SizedBox.shrink(),
          c: (_, __) {
            for (final raw in raws) {
              final m = vsbwk2(raw);
              if (m != null) got.add((m['n'] ?? '').toString());
            }
            return const Scaffold(body: Text('S1'));
          },
          f: dio,
          g: Duration.zero,
          k: () async => <ConnectivityResult>[ConnectivityResult.wifi],
          l: () => const Stream<List<ConnectivityResult>>.empty(),
        ),
      ),
    );

    await tester.pump(); // post-frame
    await tester.pumpAndSettle();

    expect(got, containsAll(<String>['evt_a', 'evt_b']));
  });

  testWidgets('Protocol B messages reach native hook (platform 2)', (WidgetTester tester) async {
    final got = <String>[];
    final dio = Dio();
    dio.httpClientAdapter = _FakeAdapter(
      body:
          '[{"vsbwkPlaf":"2","vsbwkUr":"https://example.com","vsbwkEnty":"","vsbwkAfky":"","vsbwkAid":"","vsbwkAdky":"","vsbwkAdelist":"{}"}]',
    );

    const raws = <String>[
      '{"eventName":"evt_c","eventValue":{"y":2}}',
      '{"eventName":"evt_d","eventValue":"{\\"z\\":3}"}',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Vsbwk0(
          a: (_) => const SizedBox.shrink(),
          d: (_, __) {
            for (final raw in raws) {
              final m = vsbwk3(raw);
              if (m != null) got.add((m['n'] ?? '').toString());
            }
            return const Scaffold(body: Text('S2'));
          },
          f: dio,
          g: Duration.zero,
          k: () async => <ConnectivityResult>[ConnectivityResult.wifi],
          l: () => const Stream<List<ConnectivityResult>>.empty(),
        ),
      ),
    );

    await tester.pump(); // post-frame
    await tester.pumpAndSettle();

    expect(got, containsAll(<String>['evt_c', 'evt_d']));
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
