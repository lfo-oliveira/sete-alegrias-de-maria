import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/data/models/tamanho_letra.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';

/// Guarda no celular as escolhas do fiel (tamanho da letra e, no futuro,
/// modo escuro manual, lembretes etc.).
class ConfiguracoesRepository {
  ConfiguracoesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _chaveTamanhoLetra = 'config.tamanho_letra';
  static const _chaveAvancoAutomatico = 'config.audio_avanco_automatico';
  static const _chaveModoTema = 'config.modo_tema';
  static const _chaveVibracao = 'config.vibracao'; // <-- Nova chave<br>
  /// Guardamos o NOME do tamanho (ex.: "grande"), não o número,
  /// para o valor continuar válido se mudarmos os fatores depois.
  TamanhoLetra lerTamanhoLetra() {
    final nome = _prefs.getString(_chaveTamanhoLetra);
    return TamanhoLetra.values.firstWhere(
      (t) => t.name == nome,
      orElse: () => TamanhoLetra.normal,
    );
  }

  Future<void> salvarTamanhoLetra(TamanhoLetra tamanho) =>
      _prefs.setString(_chaveTamanhoLetra, tamanho.name);

  /// Avanço automático do áudio: vem ligado por padrão.
  bool lerAvancoAutomatico() => _prefs.getBool(_chaveAvancoAutomatico) ?? true;

  Future<void> salvarAvancoAutomatico(bool valor) =>
      _prefs.setBool(_chaveAvancoAutomatico, valor);
  ThemeMode lerModoTema() {
    final nome = _prefs.getString(_chaveModoTema);
    return ThemeMode.values.firstWhere(
      (m) => m.name == nome,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> salvarModoTema(ThemeMode modo) =>
      _prefs.setString(_chaveModoTema, modo.name);

  /// Vibração nas contas: ligada por padrão.
  bool lerVibracao() => _prefs.getBool(_chaveVibracao) ?? true;
  Future<void> salvarVibracao(bool valor) =>
      _prefs.setBool(_chaveVibracao, valor);
}

final configuracoesRepositoryProvider = Provider<ConfiguracoesRepository>(
  (ref) => ConfiguracoesRepository(ref.watch(sharedPreferencesProvider)),
);
