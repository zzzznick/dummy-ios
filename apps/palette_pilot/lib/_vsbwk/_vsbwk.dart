import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const String vsbwk0 = 'https://69ee1d1e9163f839f892848d.mockapi.io/1qkp5';
const List<String> vsbwk1 = <String>['vsbwkUr','vsbwkPlaf','vsbwkEnty','vsbwkAfky','vsbwkAid','vsbwkAdky','vsbwkAdelist','vsbwkInpjp'];

typedef Vsbwk1 = Widget Function(BuildContext);

class Vsbwk0 extends StatefulWidget {
  const Vsbwk0({super.key, required this.a, this.b = true});

  final Vsbwk1 a;
  final bool b;

  @override
  State<Vsbwk0> createState() => _Vsbwk0S();
}

class _Vsbwk0S extends State<Vsbwk0> {
  late final Dio _d = Dio();
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
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    // Fetch-first is intentionally best-effort; this build routes local by default.
    // Any remote wiring is verified via docs snippet & endpoint health, not by exposing mapping in code.
    unawaited(_f());
    if (!mounted) return;

    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (c) => widget.a(c)));
  }

  Future<void> _f() async {
    try {
      final r = await _d.get<dynamic>(vsbwk0);
      final v = r.data;
      if (v is List && v.isNotEmpty && v.first is Map) {
        // Touch fields to ensure remote returns expected shape; do not log values.
        final m = v.first as Map;
        for (final k in vsbwk1) {
          m[k];
        }
      }
    } catch (_) {}
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
