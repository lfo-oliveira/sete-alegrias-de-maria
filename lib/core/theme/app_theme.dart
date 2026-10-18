import 'package:flutter/material.dart';

/// Tema franciscano: tons terrosos (marrom e bege).
/// Para mudar as cores do app, edite apenas este arquivo.
abstract final class AppTheme {
  // Modo claro
  static const _marrom = Color(0xFF6B4A2F);
  static const _bege = Color(0xFFF5EBDD);
  static const _textoClaro = Color(0xFF3B2A1B);

  // Modo escuro (sem preto puro nem branco forte)
  static const _fundoEscuro = Color(0xFF2B2018);
  static const _textoEscuro = Color(0xFFE8DCC8);

  static ThemeData get claro => _montar(
        ColorScheme.fromSeed(
          seedColor: _marrom,
          brightness: Brightness.light,
        ).copyWith(
          surface: _bege,
          onSurface: _textoClaro,
        ),
      );

  static ThemeData get escuro => _montar(
        ColorScheme.fromSeed(
          seedColor: _marrom,
          brightness: Brightness.dark,
        ).copyWith(
          surface: _fundoEscuro,
          onSurface: _textoEscuro,
        ),
      );

  static ThemeData _montar(ColorScheme cores) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cores,
      scaffoldBackgroundColor: cores.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: cores.surface,
        foregroundColor: cores.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
