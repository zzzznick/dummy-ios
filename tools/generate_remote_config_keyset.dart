import 'dart:io';
import 'dart:math';

/// Generates per-app `remote_config_spec.dart` and a README snippet.
///
/// Usage:
///   dart run tools/generate_remote_config_keyset.dart <app_dir> [prefix] [--force] [--endpoint <url>]
///
/// Example:
///   dart run tools/generate_remote_config_keyset.dart apps/my_jacket
///
/// Output:
/// - Writes: <app_dir>/lib/boot/remote_config_spec.dart
/// - Prints: a markdown snippet (mapping + remote_url example)
void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/generate_remote_config_keyset.dart <app_dir> [prefix] [--force] [--endpoint <url>]',
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

  final libBootDir = Directory('${appDir.path}/lib/boot');
  if (!libBootDir.existsSync()) {
    libBootDir.createSync(recursive: true);
  }

  final appName = appDir.uri.pathSegments.where((s) => s.isNotEmpty).last;

  final prefix = (filtered.length >= 2 && filtered[1].trim().isNotEmpty)
      ? filtered[1].trim()
      : _randomPrefix();

  final endpointValue = (endpoint?.trim().isNotEmpty ?? false)
      ? endpoint!.trim()
      : 'https://example.com/remote-config/$appName';

  final specFile = File('${libBootDir.path}/remote_config_spec.dart');
  if (specFile.existsSync() && !force) {
    stderr.writeln(
      'Refusing to overwrite existing file: ${specFile.path}\n'
      'Re-run with --force if you intend to replace it.',
    );
    exitCode = 73;
    return;
  }

  specFile.writeAsStringSync(_renderSpecDart(prefix, endpointValue));

  final spec = _parseSpec(specFile.readAsStringSync());
  if (spec == null) {
    stderr.writeln('Failed to parse generated spec: ${specFile.path}');
    exitCode = 70;
    return;
  }

  stdout.writeln(_renderReadmeSnippetFromSpec(spec));
}

String _randomPrefix() {
  const letters = 'abcdefghijklmnopqrstuvwxyz';
  final rnd = Random.secure();
  return List<String>.generate(
    5,
    (_) => letters[rnd.nextInt(letters.length)],
  ).join();
}

String? _readFlagValue(List<String> args, String flag) {
  final idx = args.indexOf(flag);
  if (idx < 0) return null;
  if (idx + 1 >= args.length) return '';
  return args[idx + 1];
}

String _renderSpecDart(String prefix, String endpoint) {
  String esc(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
  final ep = esc(endpoint);

  final url = '${prefix}Ur';
  final platform = '${prefix}Plaf';
  final inappjump = '${prefix}Inpjp';
  final eventtype = '${prefix}Enty';
  final afkey = '${prefix}Afky';
  final appid = '${prefix}Aid';
  final adkey = '${prefix}Adky';
  final adeventlist = '${prefix}Adelist';

  return [
    "import '../app_common/remote_config/remote_config.dart';",
    '',
    '/// Remote config endpoint for this app (aka `remote_url`).',
    '///',
    '/// Each jacket app SHOULD use a different endpoint.',
    "const String remoteConfigEndpoint = '$ep';",
    '',
    '/// Per-app random keyset for remote config.',
    '///',
    '/// This app uses random field names; see README / 马甲包复核说明.md for mapping',
    '/// and a ready-to-copy response example.',
    'const RemoteConfigKeys remoteConfigKeys = RemoteConfigKeys(',
    "  url: '$url',",
    "  platform: '$platform',",
    "  eventType: '$eventtype',",
    "  afKey: '$afkey',",
    "  appId: '$appid',",
    "  adKey: '$adkey',",
    "  adEventList: '$adeventlist',",
    "  inAppJump: '$inappjump',",
    ');',
    '',
  ].join('\n');
}

class _Spec {
  _Spec({
    required this.endpoint,
    required this.url,
    required this.platform,
    required this.inappjump,
    required this.eventtype,
    required this.afkey,
    required this.appid,
    required this.adkey,
    required this.adeventlist,
  });

  final String endpoint;
  final String url;
  final String platform;
  final String inappjump;
  final String eventtype;
  final String afkey;
  final String appid;
  final String adkey;
  final String adeventlist;
}

_Spec? _parseSpec(String src) {
  final endpointMatch = RegExp(
    r"const\s+String\s+remoteConfigEndpoint\s*=\s*'([^']*)';",
  ).firstMatch(src);
  if (endpointMatch == null) return null;
  final endpoint = endpointMatch.group(1)!;

  String? field(String name) {
    final m = RegExp("($name)\\s*:\\s*'([^']*)'").firstMatch(src);
    return m?.group(2);
  }

  final url = field('url');
  final platform = field('platform');
  final inappjump = field('inAppJump');
  final eventtype = field('eventType');
  final afkey = field('afKey');
  final appid = field('appId');
  final adkey = field('adKey');
  final adeventlist = field('adEventList');

  if ([
    url,
    platform,
    inappjump,
    eventtype,
    afkey,
    appid,
    adkey,
    adeventlist,
  ].any((e) => e == null)) {
    return null;
  }

  return _Spec(
    endpoint: endpoint,
    url: url!,
    platform: platform!,
    inappjump: inappjump!,
    eventtype: eventtype!,
    afkey: afkey!,
    appid: appid!,
    adkey: adkey!,
    adeventlist: adeventlist!,
  );
}

String _renderReadmeSnippetFromSpec(_Spec spec) {
  final endpoint = spec.endpoint;

  String jsonEscape(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  const adEventList =
      '{"firstDepositArrival":"aaaaa","startTrial":"aaaaa","deposit":"aaaaa","withdraw":"aaaaa","firstOpen":"aaaaa","register":"aaaaa","depositSubmit":"aaaaa","firstDeposit":"aaaaa"}';

  final mapping = <String, String>{
    spec.url: 'url',
    spec.platform: 'platform',
    spec.inappjump: 'inappjump',
    spec.eventtype: 'eventtype',
    spec.afkey: 'afkey',
    spec.appid: 'appid',
    spec.adkey: 'adkey',
    spec.adeventlist: 'adeventlist',
  };

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
    '  "${spec.url}": "url",',
    '  "${spec.platform}": "platform",',
    '  "${spec.inappjump}": "inappjump",',
    '  "${spec.eventtype}": "eventtype",',
    '  "${spec.afkey}": "afkey",',
    '  "${spec.appid}": "appid",',
    '  "${spec.adkey}": "adkey",',
    '  "${spec.adeventlist}": "adeventlist"',
    '}',
    '```',
    '',
    '### `remote_url` response example (first item is used)',
    '',
    '```json',
    '[',
    '  {',
    '    "${spec.url}": "",',
    '    "${spec.platform}": "0",',
    '    "${spec.eventtype}": "ad",',
    '    "${spec.inappjump}": "false",',
    '    "${spec.afkey}": "afkeyaaa",',
    '    "${spec.appid}": "000000",',
    '    "${spec.adkey}": "adkeybbbb",',
    '    "${spec.adeventlist}": "${jsonEscape(adEventList)}"',
    '  }',
    ']',
    '```',
    '',
  ].join('\n');
}
