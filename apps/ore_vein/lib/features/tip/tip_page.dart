import 'package:flutter/material.dart';

import '../../app/settings/app_settings_controller.dart';

class TipPage extends StatefulWidget {
  const TipPage({super.key, required this.settings});

  final AppSettingsController settings;

  @override
  State<TipPage> createState() => _TipPageState();
}

class _TipPageState extends State<TipPage> {
  late final TextEditingController _bill;
  double _tipPercent = 18;
  int _split = 1;
  var _seededTip = false;

  @override
  void initState() {
    super.initState();
    _bill = TextEditingController(text: '50.00');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _seededTip) return;
      _seededTip = true;
      setState(() => _tipPercent = widget.settings.value.defaultTipPercent);
    });
  }

  @override
  void dispose() {
    _bill.dispose();
    super.dispose();
  }

  double? _billVal() => double.tryParse(_bill.text.replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final bill = _billVal() ?? 0;
        final tip = bill * (_tipPercent / 100.0);
        final total = bill + tip;
        final per = _split <= 0 ? total : total / _split;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            TextField(
              controller: _bill,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Bill amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text('Tip ${_tipPercent.toStringAsFixed(0)}%'),
            Slider(
              value: _tipPercent.clamp(5, 35),
              min: 5,
              max: 35,
              divisions: 30,
              label: '${_tipPercent.round()}%',
              onChanged: (v) => setState(() => _tipPercent = v),
            ),
            const SizedBox(height: 8),
            Text('Split among'),
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: _split > 1 ? () => setState(() => _split--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_split', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  onPressed: _split < 20 ? () => setState(() => _split++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _row('Tip', '\$${tip.toStringAsFixed(2)}'),
                    _row('Total', '\$${total.toStringAsFixed(2)}'),
                    const Divider(height: 24),
                    _row('Per person', '\$${per.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(v),
        ],
      ),
    );
  }
}
