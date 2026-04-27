import 'dart:math';

import 'package:flutter/material.dart';

import '../app/settings/app_settings.dart';

String formatColor(Color c, ColorFormat format) {
  switch (format) {
    case ColorFormat.hex:
      return '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';
    case ColorFormat.rgb:
      return 'rgb(${c.red}, ${c.green}, ${c.blue})';
    case ColorFormat.hsl:
      final hsl = HSLColor.fromColor(c);
      return 'hsl(${hsl.hue.round()}, ${(hsl.saturation * 100).round()}%, ${(hsl.lightness * 100).round()}%)';
  }
}

double relativeLuminance(Color c) {
  double f(int x) {
    final v = x / 255.0;
    return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = f(c.red);
  final g = f(c.green);
  final b = f(c.blue);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrastRatio(Color a, Color b) {
  final l1 = relativeLuminance(a);
  final l2 = relativeLuminance(b);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

bool meetsTarget(double ratio, ContrastTarget target) {
  switch (target) {
    case ContrastTarget.aa:
      return ratio >= 4.5;
    case ContrastTarget.aaa:
      return ratio >= 7.0;
  }
}

