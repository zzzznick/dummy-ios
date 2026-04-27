import 'dart:ui';

enum ColorFormat { hex, rgb, hsl }

enum ContrastTarget { aa, aaa }

class AppSettings {
  const AppSettings({
    required this.seedColor,
    required this.colorFormat,
    required this.contrastTarget,
    required this.exportPadding,
  });

  final Color seedColor;
  final ColorFormat colorFormat;
  final ContrastTarget contrastTarget;

  /// Extra padding used by Export previews (0..48).
  final int exportPadding;

  AppSettings copyWith({
    Color? seedColor,
    ColorFormat? colorFormat,
    ContrastTarget? contrastTarget,
    int? exportPadding,
  }) {
    return AppSettings(
      seedColor: seedColor ?? this.seedColor,
      colorFormat: colorFormat ?? this.colorFormat,
      contrastTarget: contrastTarget ?? this.contrastTarget,
      exportPadding: exportPadding ?? this.exportPadding,
    );
  }

  static const AppSettings defaults = AppSettings(
    seedColor: Color(0xFF5E60CE),
    colorFormat: ColorFormat.hex,
    contrastTarget: ContrastTarget.aa,
    exportPadding: 16,
  );
}

