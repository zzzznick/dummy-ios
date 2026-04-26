import 'dart:io';
import 'dart:math';

/// Generates per-app `remote_config_keys.dart` and a README snippet.
///
/// Usage:
///   dart run tools/generate_remote_config_keyset.dart <app_dir> [prefix] [--force] [--compat] [--endpoint <url>]
///
/// Example:
///   dart run tools/generate_remote_config_keyset.dart apps/my_jacket
///
/// Output:
/// - Writes: <app_dir>/lib/boot/remote_config_keys.dart
/// - Writes: <app_dir>/lib/boot/remote_config_endpoint.dart (if --endpoint is provided, or if missing)
/// - Prints: a markdown snippet (mapping + remote_url example)
void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/generate_remote_config_keyset.dart <app_dir> [prefix] [--force] [--compat] [--endpoint <url>]',
    );
    exitCode = 64;
    return;
  }

  final force = args.contains('--force');
  final compat = args.contains('--compat');
  final endpoint = _readFlagValue(args, '--endpoint');

  final filtered = <String>[];
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--force' || a == '--compat') continue;
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

  final libBootDir = Directory('${appDir.path}/lib/boot');
  if (!libBootDir.existsSync()) {
    libBootDir.createSync(recursive: true);
  }

  final appName = appDir.uri.pathSegments.where((s) => s.isNotEmpty).last;

  final prefix = (filtered.length >= 2 && filtered[1].trim().isNotEmpty)
      ? filtered[1].trim()
      : _randomPrefix();

  final mapping = <String, String>{
    '${prefix}Ur': 'url',
    '${prefix}Plaf': 'platform',
    '${prefix}Inpjp': 'inappjump',
    '${prefix}Enty': 'eventtype',
    '${prefix}Afky': 'afkey',
    '${prefix}Aid': 'appid',
    '${prefix}Adky': 'adkey',
    '${prefix}Adelist': 'adeventlist',
  };

  final dartFile = File('${libBootDir.path}/remote_config_keys.dart');
  if (dartFile.existsSync() && !force) {
    stderr.writeln(
      'Refusing to overwrite existing file: ${dartFile.path}\n'
      'Re-run with --force if you intend to replace it.',
    );
    exitCode = 73;
    return;
  }
  dartFile.writeAsStringSync(_renderDart(mapping, compat: compat));

  final endpointFile = File('${libBootDir.path}/remote_config_endpoint.dart');
  final endpointValue = (endpoint?.trim().isNotEmpty ?? false)
      ? endpoint!.trim()
      : 'https://example.com/remote-config/$appName';
  if (!endpointFile.existsSync() || force || endpoint != null) {
    if (endpointFile.existsSync() && !force && endpoint == null) {
      // Keep existing endpoint if caller didn't request overwrite.
    } else if (endpointFile.existsSync() && !force && endpoint != null) {
      stderr.writeln(
        'Refusing to overwrite existing file: ${endpointFile.path}\n'
        'Re-run with --force if you intend to replace it.',
      );
      exitCode = 73;
      return;
    } else {
      endpointFile.writeAsStringSync(_renderEndpointDart(endpointValue));
    }
  }

  stdout.writeln(_renderReadmeSnippet(mapping, endpointValue));
}

String _randomPrefix() {
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

String _renderDart(Map<String, String> mapping, {required bool compat}) {
  final bySemantic = <String, String>{for (final e in mapping.entries) e.value: e.key};

  // Keep the file stable and easy to grep: `remoteConfigKeys` constant.
  final lines = <String>[
    "import 'package:app_common/app_common.dart';",
    '',
    'const RemoteConfigKeys remoteConfigKeys = RemoteConfigKeys(',
    "  url: '${bySemantic['url']}',",
    "  platform: '${bySemantic['platform']}',",
    "  eventType: '${bySemantic['eventtype']}',",
    "  afKey: '${bySemantic['afkey']}',",
    "  appId: '${bySemantic['appid']}',",
    "  adKey: '${bySemantic['adkey']}',",
    "  adEventList: '${bySemantic['adeventlist']}',",
    "  inAppJump: '${bySemantic['inappjump']}',",
    ');',
  ];

  if (compat) {
    lines.addAll(<String>[
      '',
      '/// Optional compatibility fallback for plaintext keys during migration windows.',
      'const RemoteConfigKeys remoteConfigFallbackKeys = RemoteConfigKeys(',
      "  url: 'url',",
      "  platform: 'platform',",
      "  eventType: 'eventtype',",
      "  afKey: 'afkey',",
      "  appId: 'appid',",
      "  adKey: 'adkey',",
      "  adEventList: 'adeventlist',",
      "  inAppJump: 'inappjump',",
      ');',
    ]);
  }

  lines.add('');
  return lines.join('\n');
}

String _renderEndpointDart(String endpoint) {
  final escaped = endpoint.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
  return [
    '/// Remote config endpoint for this app (aka `remote_url`).',
    '///',
    '/// Each jacket app SHOULD use a different endpoint.',
    "const String remoteConfigEndpoint = '$escaped';",
    '',
  ].join('\n');
}

String _renderReadmeSnippet(Map<String, String> mapping, String endpoint) {
  final bySemantic = <String, String>{for (final e in mapping.entries) e.value: e.key};

  String jsonEscape(String s) => s.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  const adEventList = '{"firstDepositArrival":"aaaaa","startTrial":"aaaaa","deposit":"aaaaa","withdraw":"aaaaa","firstOpen":"aaaaa","register":"aaaaa","depositSubmit":"aaaaa","firstDeposit":"aaaaa"}';

  return [
    '## Remote config (`remote_url`)',
    '',
    '### Endpoint',
    '',
    '`$endpoint`',
    '',
    '### Field mapping',
    '',
    'The remote config JSON uses per-app random keys. Configure your MockAPI/remote endpoint to respond with these keys.',
    '',
    '### Mapping (random key → semantic field)',
    '',
    '```json',
    '{',
    '  "${mapping.keys.elementAt(0)}": "${mapping.values.elementAt(0)}",',
    '  "${mapping.keys.elementAt(1)}": "${mapping.values.elementAt(1)}",',
    '  "${mapping.keys.elementAt(2)}": "${mapping.values.elementAt(2)}",',
    '  "${mapping.keys.elementAt(3)}": "${mapping.values.elementAt(3)}",',
    '  "${mapping.keys.elementAt(4)}": "${mapping.values.elementAt(4)}",',
    '  "${mapping.keys.elementAt(5)}": "${mapping.values.elementAt(5)}",',
    '  "${mapping.keys.elementAt(6)}": "${mapping.values.elementAt(6)}",',
    '  "${mapping.keys.elementAt(7)}": "${mapping.values.elementAt(7)}"',
    '}',
    '```',
    '',
    '### `remote_url` response example (first item is used)',
    '',
    '```json',
    '[',
    '  {',
    '    "${bySemantic['url']}": "",',
    '    "${bySemantic['platform']}": "0",',
    '    "${bySemantic['eventtype']}": "ad",',
    '    "${bySemantic['inappjump']}": "false",',
    '    "${bySemantic['afkey']}": "afkeyaaa",',
    '    "${bySemantic['appid']}": "000000",',
    '    "${bySemantic['adkey']}": "adkeybbbb",',
    '    "${bySemantic['adeventlist']}": "${jsonEscape(adEventList)}"',
    '  }',
    ']',
    '```',
    '',
  ].join('\n');
}

