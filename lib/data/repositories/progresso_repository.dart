import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Acesso ao SharedPreferences. É criado uma vez no main.dart e entregue
/// ao app por aqui (assim os testes podem trocar por um falso).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider precisa ser sobrescrito no main.dart',
  ),
);

/// Guarda no celular onde o fiel parou no terço.
/// Próximos passos: histórico (terços rezados, dias seguidos) entra AQUI.
class ProgressoRepository {
  ProgressoRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _chaveIndice = 'terco.indice_atual';

  /// Índice do passo em que o fiel parou, ou null se não houver.
  int? lerIndice() => _prefs.getInt(_chaveIndice);

  Future<void> salvarIndice(int indice) => _prefs.setInt(_chaveIndice, indice);

  Future<void> limpar() => _prefs.remove(_chaveIndice);
}

final progressoRepositoryProvider = Provider<ProgressoRepository>(
  (ref) => ProgressoRepository(ref.watch(sharedPreferencesProvider)),
);
