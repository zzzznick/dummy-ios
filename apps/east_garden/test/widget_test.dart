import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:east_garden/_xvhrt/_xvhrt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Boot gate renders East Garden bloom layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEC407A)),
          useMaterial3: true,
        ),
        home: Xvhrt0(
          a: (_) => const SizedBox.shrink(),
          b: false,
        ),
      ),
    );

    expect(find.text('East Garden'), findsOneWidget);
    expect(find.text('Quiet hands, steady winds ahead'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('eg_boot_gate')), findsOneWidget);
  });

  testWidgets('Routes to type-1 shell when configured', (WidgetTester tester) async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeAdapter(
      body: '[{"xvhrtPlaf":"1","xvhrtUr":"https://example.com"}]',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Xvhrt0(
          a: (_) => const SizedBox.shrink(),
          c: (_, _) => const Scaffold(body: Text('S1')),
          f: dio,
          g: Duration.zero,
          k: () async => <ConnectivityResult>[ConnectivityResult.wifi],
          l: () => const Stream<List<ConnectivityResult>>.empty(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('S1'), findsOneWidget);
  });

  test('Generated shell has no visible title strings', () {
    final src = File('lib/_xvhrt/_xvhrt.dart').readAsStringSync();
    expect(src.contains('Workspace'), isFalse);
    expect(src.contains('Browse'), isFalse);
  });

  test('Generated shell uses container black frame only', () {
    final src = File('lib/_xvhrt/_xvhrt.dart').readAsStringSync();
    expect(src.contains('SystemChrome'), isFalse);
    expect(src.contains('SystemUiOverlayStyle'), isFalse);
    expect(src.contains('Colors.black'), isTrue);
    expect(src.contains('SafeArea('), isTrue);
  });

  test('Generated shell injects jsBridge and WgPackage', () {
    final src = File('lib/_xvhrt/_xvhrt.dart').readAsStringSync();
    expect(src.contains('window.jsBridge'), isTrue);
    expect(src.contains('jsBridge.postMessage'), isTrue);
    expect(src.contains('window.WgPackage'), isTrue);
    expect(src.contains('PackageInfo.fromPlatform'), isTrue);
  });

  test('Generated shell intercepts t.me and popup navigation', () {
    final src = File('lib/_xvhrt/_xvhrt.dart').readAsStringSync();
    expect(src.contains('onNavigationRequest'), isTrue);
    expect(src.contains("contains('t.me')"), isTrue);
    expect(src.contains('!req.isMainFrame'), isTrue);
  });

  test('Generated shell handles openWindow/openSafari with inAppJump', () {
    final src = File('lib/_xvhrt/_xvhrt.dart').readAsStringSync();
    expect(src.contains("name != 'openWindow' && name != 'openSafari'"), isTrue);
    expect(src.contains("name != 'openWindow'"), isTrue);
    expect(src.contains('widget.j'), isTrue);
    expect(src.contains('loadRequest'), isTrue);
    expect(src.contains('LaunchMode.externalApplication'), isTrue);
  });

  test('Generated attribution parity includes revenue rules', () {
    final src = File('lib/_xvhrt/_xvhrt.dart').readAsStringSync();
    expect(src.contains('withdrawOrderSuccess'), isTrue);
    expect(
      src.contains("payload['amount'] ?? payload['af_revenue'] ?? payload['price']"),
      isTrue,
    );
    expect(src.contains("'af_revenue'"), isTrue);
    expect(src.contains("'af_currency'"), isTrue);
    expect(src.contains('setRevenue('), isTrue);
  });

  testWidgets('Protocol A messages reach native hook (platform 1)', (WidgetTester tester) async {
    final got = <String>[];
    final dio = Dio();
    dio.httpClientAdapter = _FakeAdapter(
      body:
          '[{"xvhrtPlaf":"1","xvhrtUr":"https://example.com","xvhrtEnty":"","xvhrtAfky":"","xvhrtAid":"","xvhrtAdky":"","xvhrtAdelist":"{}","xvhrtInpjp":"false"}]',
    );

    const raws = <String>[
      '{"name":"evt_a","data":{"k":"v"}}',
      'evt_b+{"x":1}',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Xvhrt0(
          a: (_) => const SizedBox.shrink(),
          c: (_, _) {
            for (final raw in raws) {
              final m = xvhrt2(raw);
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

    await tester.pump();
    await tester.pumpAndSettle();

    expect(got, containsAll(<String>['evt_a', 'evt_b']));
  });

  testWidgets('Protocol B messages reach native hook (platform 2)', (WidgetTester tester) async {
    final got = <String>[];
    final dio = Dio();
    dio.httpClientAdapter = _FakeAdapter(
      body:
          '[{"xvhrtPlaf":"2","xvhrtUr":"https://example.com","xvhrtEnty":"","xvhrtAfky":"","xvhrtAid":"","xvhrtAdky":"","xvhrtAdelist":"{}","xvhrtInpjp":"false"}]',
    );

    const raws = <String>[
      '{"eventName":"evt_c","eventValue":{"y":2}}',
      '{"eventName":"evt_d","eventValue":"{\\"z\\":3}"}',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Xvhrt0(
          a: (_) => const SizedBox.shrink(),
          d: (_, _) {
            for (final raw in raws) {
              final m = xvhrt3(raw);
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

    await tester.pump();
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
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
