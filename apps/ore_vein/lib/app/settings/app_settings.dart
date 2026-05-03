import 'package:flutter/material.dart';

enum TimerFace { minimal, rings, bold }

enum NumberDensity { comfortable, compact }

class AppSettings {
  const AppSettings({
    required this.seedColor,
    required this.defaultTipPercent,
    required this.timerFace,
    required this.listsNewestFirst,
    required this.numberDensity,
  });

  final Color seedColor;
  final double defaultTipPercent;
  final TimerFace timerFace;
  final bool listsNewestFirst;
  final NumberDensity numberDensity;

  static const AppSettings defaults = AppSettings(
    seedColor: Color(0xFF006978),
    defaultTipPercent: 18,
    timerFace: TimerFace.rings,
    listsNewestFirst: true,
    numberDensity: NumberDensity.comfortable,
  );

  AppSettings copyWith({
    Color? seedColor,
    double? defaultTipPercent,
    TimerFace? timerFace,
    bool? listsNewestFirst,
    NumberDensity? numberDensity,
  }) {
    return AppSettings(
      seedColor: seedColor ?? this.seedColor,
      defaultTipPercent: defaultTipPercent ?? this.defaultTipPercent,
      timerFace: timerFace ?? this.timerFace,
      listsNewestFirst: listsNewestFirst ?? this.listsNewestFirst,
      numberDensity: numberDensity ?? this.numberDensity,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'seed': seedColor.value,
        'tip': defaultTipPercent,
        'face': timerFace.index,
        'lists': listsNewestFirst,
        'dense': numberDensity.index,
      };

  static AppSettings fromJson(Map<String, dynamic> j) {
    final seed = (j['seed'] is int) ? j['seed'] as int : int.tryParse('${j['seed']}') ?? 0xFF006978;
    final tip = (j['tip'] is num) ? (j['tip'] as num).toDouble() : 18.0;
    final faceIdx = (j['face'] is int) ? j['face'] as int : 1;
    final lists = j['lists'] == true;
    final denseIdx = (j['dense'] is int) ? j['dense'] as int : 0;
    return AppSettings(
      seedColor: Color(seed),
      defaultTipPercent: tip.clamp(5, 35),
      timerFace: TimerFace.values[faceIdx.clamp(0, TimerFace.values.length - 1)],
      listsNewestFirst: lists,
      numberDensity: NumberDensity.values[denseIdx.clamp(0, NumberDensity.values.length - 1)],
    );
  }
}
