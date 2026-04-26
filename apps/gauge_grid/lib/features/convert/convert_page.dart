import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/gauge_scope.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  final TextEditingController _value = TextEditingController(text: '1');
  String _from = 'cm';
  String _to = 'in';
  String _result = '—';
  bool _syncedFromSettings = false;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _recalc();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedFromSettings) return;
    _syncedFromSettings = true;
    final u = GaugeScope.of(context).defaultLengthUnit;
    if (u == 'mm' || u == 'cm' || u == 'in') {
      _from = u;
    }
  }

  double? _asMm(double v, String u) {
    switch (u) {
      case 'mm':
        return v;
      case 'cm':
        return v * 10;
      case 'in':
        return v * 25.4;
      default:
        return null;
    }
  }

  String _fromMm(double mm, String u) {
    switch (u) {
      case 'mm':
        return mm.toStringAsFixed(2);
      case 'cm':
        return (mm / 10).toStringAsFixed(3);
      case 'in':
        return (mm / 25.4).toStringAsFixed(4);
      default:
        return '—';
    }
  }

  void _recalc() {
    final p = double.tryParse(_value.text.replaceAll(',', '.'));
    if (p == null) {
      setState(() => _result = '—');
      return;
    }
    final store = GaugeScope.of(context);
    final d = store.decimalPlaces;
    final mm = _asMm(p, _from);
    if (mm == null) return;
    final out = _fromMm(mm, _to);
    setState(() {
      final n = double.tryParse(out);
      _result = n == null ? out : n.toStringAsFixed(d);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = GaugeScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Length conversion for workshop estimates (does not read cells automatically).',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _value,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) {
              HapticFeedback.selectionClick();
              _recalc();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _from,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(value: 'mm', child: Text('From mm')),
                    DropdownMenuItem(value: 'cm', child: Text('From cm')),
                    DropdownMenuItem(value: 'in', child: Text('From in')),
                  ],
                  onChanged: (s) {
                    if (s == null) return;
                    setState(() => _from = s);
                    _recalc();
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _to,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(value: 'mm', child: Text('To mm')),
                    DropdownMenuItem(value: 'cm', child: Text('To cm')),
                    DropdownMenuItem(value: 'in', child: Text('To in')),
                  ],
                  onChanged: (s) {
                    if (s == null) return;
                    setState(() => _to = s);
                    _recalc();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Result', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            _result,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          Text(
            'Default unit in Settings is ${store.defaultLengthUnit}; Convert starts from that when you open the tab once.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
