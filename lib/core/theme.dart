import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

/// Dark Tactical Vector palette. Four spec colors plus the minimum support set:
/// hostile red (enemies only), ice (intel), and three neutral text/line steps.
abstract final class Palette {
  static const carbon = Color(0xFF0B0D12); // Carbon Matrix — app ground
  static const slate = Color(0xFF161B22); // Stealth Slate — panels
  static const slateHi = Color(0xFF1D242E); // raised / pressed panel
  static const line = Color(0xFF2A3342); // hairlines, neutral hex edges
  static const mint = Color(0xFF00FFA3); // Neon Mint — your territory
  static const amber = Color(0xFFFFB800); // Core Amber — hubs, relays, costs
  static const hostile = Color(0xFFFF3B5C); // rival factions only
  static const ice = Color(0xFF5CC8FF); // intel
  static const text = Color(0xFFE6EDF3);
  static const textDim = Color(0xFF8B95A5);
  static const textFaint = Color(0xFF566070);
}

/// System bars over dark surfaces: every screen except the white sunlight map.
const kDarkBars = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Palette.carbon,
  systemNavigationBarIconBrightness: Brightness.light,
);

/// Colours for everything painted over the basemap. [dark] is the regular
/// palette on the carbon map. [sun] is for the white sunlight map: neon on
/// white washes out outdoors, so it swaps in deep, saturated inks and heavier
/// fills and strokes.
class MapInk {
  const MapInk({
    required this.light,
    required this.ground,
    required this.mine,
    required this.hub,
    required this.hostile,
    required this.intel,
    required this.ink,
    required this.dim,
    required this.shade,
    required this.fill,
    required this.stroke,
  });

  final bool light;

  /// Basemap ground: knock-outs behind glyphs and label halos.
  final Color ground;
  final Color mine;
  final Color hub;
  final Color hostile;
  final Color intel;

  /// Your position, selection reticle, neutral marks.
  final Color ink;
  final Color dim;

  /// Tint over ground where nothing can be planted.
  final Color shade;

  /// Multiplier on zone fill opacity, and extra stroke width in pixels.
  final double fill;
  final double stroke;

  static const dark = MapInk(
    light: false,
    ground: Palette.carbon,
    mine: Palette.mint,
    hub: Palette.amber,
    hostile: Palette.hostile,
    intel: Palette.ice,
    ink: Palette.text,
    dim: Palette.textDim,
    shade: Color(0x800B0D12),
    fill: 1,
    stroke: 0,
  );

  static const sun = MapInk(
    light: true,
    ground: Color(0xFFFFFFFF),
    mine: Color(0xFF00794C),
    hub: Color(0xFFB45300),
    hostile: Color(0xFFC8102E),
    intel: Color(0xFF0061B0),
    ink: Color(0xFF0B0D12),
    dim: Color(0xFF414B5A),
    shade: Color(0x330B0D12),
    fill: 1.7,
    stroke: 0.8,
  );
}

abstract final class Fonts {
  static const display = 'ChakraPetch';
  static const mono = 'JetBrainsMono';
}

abstract final class TextStyles {
  static const display = TextStyle(
    fontFamily: Fonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    letterSpacing: 0.6,
    color: Palette.text,
    height: 1.1,
  );
  static const title = TextStyle(
    fontFamily: Fonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.8,
    color: Palette.text,
    height: 1.15,
  );
  static const body = TextStyle(
    fontFamily: Fonts.display,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: Palette.text,
    height: 1.3,
  );
  static const bodyDim = TextStyle(
    fontFamily: Fonts.display,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: Palette.textDim,
    height: 1.3,
  );

  /// Eyebrow labels: mono, tracked out, uppercase.
  static const label = TextStyle(
    fontFamily: Fonts.mono,
    fontWeight: FontWeight.w500,
    fontSize: 10,
    letterSpacing: 1.6,
    color: Palette.textDim,
    height: 1.2,
  );
  static const data = TextStyle(
    fontFamily: Fonts.mono,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Palette.text,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.2,
  );
  static const dataSmall = TextStyle(
    fontFamily: Fonts.mono,
    fontWeight: FontWeight.w500,
    fontSize: 11.5,
    color: Palette.textDim,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.25,
  );
}

/// Cut-corner panel shape used by every console surface.
ShapeBorder chamfer([double cut = 10, Color? side]) => BeveledRectangleBorder(
  borderRadius: BorderRadius.only(topLeft: Radius.circular(cut), bottomRight: Radius.circular(cut)),
  side: side == null ? BorderSide.none : BorderSide(color: side, width: 1),
);

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    surface: Palette.slate,
    primary: Palette.mint,
    onPrimary: Palette.carbon,
    secondary: Palette.amber,
    onSecondary: Palette.carbon,
    error: Palette.hostile,
    onSurface: Palette.text,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Palette.carbon,
    fontFamily: Fonts.display,
    splashFactory: InkRipple.splashFactory,
    textTheme: const TextTheme(
      bodyMedium: TextStyles.body,
      bodySmall: TextStyles.bodyDim,
      titleMedium: TextStyles.title,
      labelSmall: TextStyles.label,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Palette.slateHi,
      contentTextStyle: TextStyles.body,
      behavior: SnackBarBehavior.floating,
      shape: chamfer(8, Palette.line) as OutlinedBorder,
    ),
    dividerColor: Palette.line,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Palette.carbon : Palette.textDim,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Palette.mint : Palette.slateHi,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Palette.line),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Palette.slate, modalBackgroundColor: Palette.slate),
  );
}
