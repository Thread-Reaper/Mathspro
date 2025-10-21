import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static const _kModeKey = 'theme_mode'; // 'dark' or 'light'
  static const _kDarkIndexKey = 'dark_palette_index';
  static const _kLightIndexKey = 'light_palette_index';

  static final ValueNotifier<ThemeData> notifier =
      ValueNotifier<ThemeData>(_buildDarkTheme(_darkSeeds[0]));

  static const List<Color> _darkSeeds = <Color>[
    Color(0xFFFF6D00), // vivid orange
    Color(0xFF00C2A8), // teal
    Color(0xFFFF7AB6), // lively pink
    Color(0xFF8E7CFF), // purple
    Color(0xFF9CCC65), // lime
  ];

  static const List<Color> _lightSeeds = <Color>[
    Color(0xFF2962FF), // blue
    Color(0xFF00C853), // green
    Color(0xFFFF6D00), // orange
    Color(0xFFAA00FF), // purple
    Color(0xFF00BCD4), // cyan
  ];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_kModeKey) ?? 'dark';
    final darkIdx = prefs.getInt(_kDarkIndexKey) ?? 0;
    final lightIdx = prefs.getInt(_kLightIndexKey) ?? 0;
    if (mode == 'light') {
      notifier.value = _buildLightTheme(_lightSeeds[lightIdx % _lightSeeds.length]);
    } else {
      notifier.value = _buildDarkTheme(_darkSeeds[darkIdx % _darkSeeds.length]);
    }
  }

  static Future<void> setModeAndPalette({required bool dark, required int index}) async {
    final prefs = await SharedPreferences.getInstance();
    if (dark) {
      await prefs.setString(_kModeKey, 'dark');
      await prefs.setInt(_kDarkIndexKey, index);
      notifier.value = _buildDarkTheme(_darkSeeds[index % _darkSeeds.length]);
    } else {
      await prefs.setString(_kModeKey, 'light');
      await prefs.setInt(_kLightIndexKey, index);
      notifier.value = _buildLightTheme(_lightSeeds[index % _lightSeeds.length]);
    }
  }

  static Future<Map<String, dynamic>> getCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_kModeKey) ?? 'dark';
    final darkIdx = prefs.getInt(_kDarkIndexKey) ?? 0;
    final lightIdx = prefs.getInt(_kLightIndexKey) ?? 0;
    return {
      'mode': mode,
      'darkIndex': darkIdx,
      'lightIndex': lightIdx,
      'darkSeeds': _darkSeeds,
      'lightSeeds': _lightSeeds,
    };
  }

  static List<Color> get darkPalettes => List.unmodifiable(_darkSeeds);
  static List<Color> get lightPalettes => List.unmodifiable(_lightSeeds);

  static ThemeData _baseTheme(ColorScheme scheme, {required bool amoled}) {
    final bg = amoled ? Colors.black : scheme.background;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: amoled ? Colors.black : scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.tertiary,
        foregroundColor: scheme.onTertiary,
      ),
      iconTheme: IconThemeData(color: scheme.tertiary),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: amoled ? const Color(0xFF0D0D0D) : scheme.surface,
        shadowColor: scheme.primary.withOpacity(0.25),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        labelStyle: TextStyle(color: scheme.onSecondaryContainer),
        selectedColor: scheme.tertiaryContainer,
        secondarySelectedColor: scheme.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: StadiumBorder(side: BorderSide(color: scheme.secondary.withOpacity(0.3))),
      ),
    );
  }

  static ThemeData _buildDarkTheme(Color seed) {
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    final scheme = base.copyWith(
      surface: const Color(0xFF0A0A0A),
      background: Colors.black,
      secondary: _darkSeeds[1], // teal accent
      tertiary: _darkSeeds[2], // pink accent
    );
    return _baseTheme(scheme, amoled: true);
  }

  static ThemeData _buildLightTheme(Color seed) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    return _baseTheme(scheme, amoled: false);
  }
}
