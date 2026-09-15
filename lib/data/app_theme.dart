import 'package:flutter/material.dart';

/// Tema romântico — rosa/coral com toques quentes.
class AppTheme {
  AppTheme._();

  static const brand = Color(0xFFFC0349); // rosa forte (cor primária)
  static const brandDark = Color(0xFFC80038);
  static const accent = Color(0xFFFF4D6D); // rosa vibrante

  /// Gradiente principal vibrante.
  static const hero = [Color(0xFFFC0349), Color(0xFFFF5177)];
  static const sunset = [Color(0xFFFC0349), Color(0xFFFF5177)];

  static LinearGradient gradient(List<Color> colors) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      );

  static ThemeData light([Color seed = brand]) {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      scaffoldBackgroundColor: const Color(0xFFFFF5F7),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }

  static ThemeData dark([Color seed = brand]) {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF1A1015),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}

/// Temas de fundo do card do casal (grátis + premium).
class CoupleTheme {
  const CoupleTheme(this.id, this.name, this.gradient, {this.premium = false});
  final String id;
  final String name;
  final List<Color> gradient;
  final bool premium;

  static const all = <CoupleTheme>[
    CoupleTheme('sunset', 'Rubi', [Color(0xFFFC0349), Color(0xFFFF5177)]),
    CoupleTheme('rosa', 'Rosa Neon', [Color(0xFFFF2D95), Color(0xFFFF6FB5)]),
    CoupleTheme('paixao', 'Paixão', [Color(0xFFF72585), Color(0xFF7209B7)],
        premium: true),
    CoupleTheme('lilas', 'Lilás', [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        premium: true),
    CoupleTheme('oceano', 'Oceano', [Color(0xFF00C6FB), Color(0xFF005BEA)],
        premium: true),
    CoupleTheme('dourado', 'Dourado', [Color(0xFFFF9A00), Color(0xFFFFCE00)],
        premium: true),
    CoupleTheme('noite', 'Noite', [Color(0xFF0F2027), Color(0xFF203A43)],
        premium: true),
  ];

  static CoupleTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);
}
