import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';

enum UnitKind { length, weight, temperature }

class UnitsPage extends StatefulWidget {
  const UnitsPage({super.key, required this.settings});

  final AppSettingsController settings;

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  UnitKind _kind = UnitKind.length;
  double _a = 1;
  String _from = 'm';
  String _to = 'ft';
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: '1');
    _amount.addListener(() => setState(() => _a = double.tryParse(_amount.text) ?? 0));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  static const _length = <String>['m', 'ft', 'mi', 'km'];
  static const _weight = <String>['kg', 'lb', 'oz'];
  static const _temp = <String>['C', 'F'];

  void _syncLabels() {
    switch (_kind) {
      case UnitKind.length:
        _from = 'm';
        _to = 'ft';
      case UnitKind.weight:
        _from = 'kg';
        _to = 'lb';
      case UnitKind.temperature:
        _from = 'C';
        _to = 'F';
    }
  }

  double _convert() {
    switch (_kind) {
      case UnitKind.length:
        return _convLength(_a, _from, _to);
      case UnitKind.weight:
        return _convWeight(_a, _from, _to);
      case UnitKind.temperature:
        return _convTemp(_a, _from, _to);
    }
  }

  double _convLength(double v, String f, String t) {
    double toMeters(double x, String u) {
      if (u == 'ft') return x * 0.3048;
      if (u == 'mi') return x * 1609.34;
      if (u == 'km') return x * 1000;
      return x;
    }

    final m = toMeters(v, f);
    if (t == 'ft') return m / 0.3048;
    if (t == 'mi') return m / 1609.34;
    if (t == 'km') return m / 1000;
    return m;
  }

  double _convWeight(double v, String f, String t) {
    double toKg(double x, String u) {
      if (u == 'lb') return x * 0.45359237;
      if (u == 'oz') return x * 0.0283495;
      return x;
    }

    final kg = toKg(v, f);
    if (t == 'lb') return kg / 0.45359237;
    if (t == 'oz') return kg / 0.0283495;
    return kg;
  }

  double _convTemp(double v, String f, String t) {
    double c = v;
    if (f == 'F') c = (v - 32) * 5 / 9;
    if (t == 'F') return c * 9 / 5 + 32;
    return c;
  }

  String _fmt(double v) {
    final compact = widget.settings.value.numberDensity == NumberDensity.compact;
    return v.abs() >= 1000
        ? v.toStringAsFixed(compact ? 1 : 2)
        : v.toStringAsFixed(compact ? 2 : 4);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final out = _convert();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            SegmentedButton<UnitKind>(
              segments: const <ButtonSegment<UnitKind>>[
                ButtonSegment(value: UnitKind.length, label: Text('Length')),
                ButtonSegment(value: UnitKind.weight, label: Text('Weight')),
                ButtonSegment(value: UnitKind.temperature, label: Text('Temp')),
              ],
              selected: <UnitKind>{_kind},
              onSelectionChanged: (s) {
                setState(() {
                  _kind = s.first;
                  _syncLabels();
                  _a = double.tryParse(_amount.text) ?? _a;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _from,
                    decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
                    items: (_kind == UnitKind.length
                            ? _length
                            : _kind == UnitKind.weight
                                ? _weight
                                : _temp)
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _from = v ?? _from),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _to,
                    decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                    items: (_kind == UnitKind.length
                            ? _length
                            : _kind == UnitKind.weight
                                ? _weight
                                : _temp)
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _to = v ?? _to),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.arrow_forward_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_fmt(out)} $_to',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
