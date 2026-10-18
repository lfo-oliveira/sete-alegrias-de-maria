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
}

final configuracoesRepositoryProvider = Provider<ConfiguracoesRepository>(
  (ref) => ConfiguracoesRepository(ref.watch(sharedPreferencesProvider)),
);
