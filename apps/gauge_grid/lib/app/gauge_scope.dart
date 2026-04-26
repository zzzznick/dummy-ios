import 'package:flutter/material.dart';

import '../data/gauge_store.dart';

class GaugeScope extends InheritedNotifier<GaugeStore> {
  const GaugeScope({super.key, required GaugeStore store, required super.child})
    : super(notifier: store);

  static GaugeStore of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<GaugeScope>();
    assert(s != null, 'GaugeScope not found');
    return s!.notifier!;
  }
}
