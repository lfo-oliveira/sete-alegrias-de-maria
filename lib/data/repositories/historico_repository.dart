import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/data/models/historico.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';

/// Guarda o histórico de oração no celular.
/// Próximo passo: exportar/restaurar backup lê e grava por AQUI.
class HistoricoRepository {
  HistoricoRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _chaveTercos = 'historico.tercos_rezados';
  static const _chaveSequencia = 'historico.sequencia';
  static const _chaveUltimoDia = 'historico.ultimo_dia';
  static const _chaveDiasRezados = 'historico.dias_rezados';

  Historico ler() {
    final ultimoDia = _lerData(_prefs.getString(_chaveUltimoDia));

    final dias = <DateTime>{};
    for (final texto in _prefs.getStringList(_chaveDiasRezados) ?? <String>[]) {
      final dia = _lerData(texto);
      if (dia != null) dias.add(dia);
    }
    // Quem já usava o app antes do calendário: o último dia também conta.
    if (ultimoDia != null) dias.add(ultimoDia);

    return Historico(
      tercosRezados: _prefs.getInt(_chaveTercos) ?? 0,
      sequenciaSalva: _prefs.getInt(_chaveSequencia) ?? 0,
      ultimoDia: ultimoDia,
      diasRezados: dias,
    );
  }

  Future<void> salvar(Historico historico) async {
    await _prefs.setInt(_chaveTercos, historico.tercosRezados);
    await _prefs.setInt(_chaveSequencia, historico.sequenciaSalva);

    final dia = historico.ultimoDia;
    if (dia == null) {
      await _prefs.remove(_chaveUltimoDia);
    } else {
      await _prefs.setString(_chaveUltimoDia, _formatar(dia));
    }

    final lista = historico.diasRezados.map(_formatar).toList()..sort();
    await _prefs.setStringList(_chaveDiasRezados, lista);
  }

  DateTime? _lerData(String? texto) =>
      texto == null ? null : DateTime.tryParse(texto);

  /// "2026-10-15": formato fixo, independente do idioma do celular.
  String _formatar(DateTime d) {
    final mes = d.month.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-$mes-$dia';
  }
}

final historicoRepositoryProvider = Provider<HistoricoRepository>(
  (ref) => HistoricoRepository(ref.watch(sharedPreferencesProvider)),
);
