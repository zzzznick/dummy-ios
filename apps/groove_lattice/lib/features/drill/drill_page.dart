import 'dart:math' as math;

import 'package:flutter/material.dart';

class DrillPage extends StatefulWidget {
  const DrillPage({super.key});

  @override
  State<DrillPage> createState() => _DrillPageState();
}

class _DrillPageState extends State<DrillPage> {
  final List<DateTime> _hits = <DateTime>[];

  void _strike() => setState(() {
        _hits.add(DateTime.now());
        if (_hits.length > 12) _hits.removeAt(0);
      });

  String _spreadLabel() {
    if (_hits.length < 3) return 'Strike the pad three times.';
    final ms = <int>[];
    for (var i = 1; i < _hits.length; i++) {
      ms.add(_hits[i].difference(_hits[i - 1]).inMilliseconds);
    }
    if (ms.isEmpty) return '';
    final avg = ms.reduce((a, b) => a + b) / ms.length;
    final varSec = ms.map((e) => math.pow(e - avg, 2)).reduce((a, b) => a + b) / ms.length;
    final dev = math.sqrt(varSec).round();
    return 'Rolling average ${_fmt(avg)} ms • spread ±$dev ms';
  }

  String _fmt(double v) => v.round().toString();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Tap-timing pad',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            _spreadLabel(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const Expanded(
            child: SizedBox(height: 8),
          ),
          SizedBox(
            height: 200,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _strike,
              child: Material(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: Text(
                    'Tap',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(_hits.clear),
                  child: const Text('Clear buffer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Samples ${_hits.length}', textAlign: TextAlign.end),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
