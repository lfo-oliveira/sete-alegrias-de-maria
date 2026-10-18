import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';

/// Guarda no celular quais lembretes estão ligados.
class LembretesRepository {
  const LembretesRepository(this._prefs);

  final SharedPreferences _prefs;

  static String _chave(int id) => 'lembretes.ativo.$id';

  /// Lembretes vêm ligados por padrão.
  bool lerAtivo(int id) => _prefs.getBool(_chave(id)) ?? true;

  Future<void> salvarAtivo(int id, bool ativo) =>
      _prefs.setBool(_chave(id), ativo);
}

final lembretesRepositoryProvider = Provider<LembretesRepository>(
  (ref) => LembretesRepository(ref.watch(sharedPreferencesProvider)),
);
