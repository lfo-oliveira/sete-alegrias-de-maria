import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembrete.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembretes_terco.dart';

/// Guarda no celular os lembretes: quais fixos estão ligados e os
/// lembretes do terço criados pelo fiel.
class LembretesRepository {
  const LembretesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const chavePersonalizados = 'lembretes.terco';

  static String _chave(int id) => 'lembretes.ativo.$id';

  /// Lembretes fixos vêm ligados por padrão.
  bool lerAtivo(int id) => _prefs.getBool(_chave(id)) ?? true;

  Future<void> salvarAtivo(int id, bool ativo) =>
      _prefs.setBool(_chave(id), ativo);

  /// Lembretes do terço criados pelo fiel.
  List<Lembrete> lerPersonalizados() {
    final texto = _prefs.getString(chavePersonalizados);
    if (texto == null) return const [];
    return _decodificar(texto) ?? const [];
  }

  Future<void> salvarPersonalizados(List<Lembrete> lembretes) {
    final lista = [
      for (final l in lembretes)
        {
          'id': l.id,
          'hora': l.hora,
          'minuto': l.minuto,
          'dias': (l.dias.toList()..sort()),
          'ativo': l.ativo,
        },
    ];
    return _prefs.setString(chavePersonalizados, jsonEncode(lista));
  }

  /// O texto guardado é válido? (usado também pelo backup)
  static bool textoValido(String texto) => _decodificar(texto) != null;

  /// Devolve null se QUALQUER item estiver inválido.
  static List<Lembrete>? _decodificar(String texto) {
    try {
      final bruto = jsonDecode(texto);
      if (bruto is! List) return null;
      final resultado = <Lembrete>[];
      for (final item in bruto) {
        final lembrete = _lerItem(item);
        if (lembrete == null) return null;
        resultado.add(lembrete);
      }
      return resultado;
    } on FormatException {
      return null;
    }
  }

  static Lembrete? _lerItem(Object? item) {
    if (item is! Map) return null;
    final id = item['id'];
    final hora = item['hora'];
    final minuto = item['minuto'];
    final dias = item['dias'];
    final ativo = item['ativo'];

    if (id is! int || id < primeiroIdPersonalizado) return null;
    if (hora is! int || hora < 0 || hora > 23) return null;
    if (minuto is! int || minuto < 0 || minuto > 59) return null;
    if (ativo is! bool) return null;
    if (dias is! List || dias.isEmpty) return null;
    if (!dias.every((d) => d is int && d >= 1 && d <= 7)) return null;

    return LembretesTerco.criar(
      id: id,
      hora: hora,
      minuto: minuto,
      dias: dias.cast<int>().toSet(),
      ativo: ativo,
    );
  }
}

final lembretesRepositoryProvider = Provider<LembretesRepository>(
  (ref) => LembretesRepository(ref.watch(sharedPreferencesProvider)),
);
