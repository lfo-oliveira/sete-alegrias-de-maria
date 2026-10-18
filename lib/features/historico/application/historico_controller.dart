import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/core/utils/relogio.dart';
import 'package:sete_alegrias_de_maria/data/models/historico.dart';
import 'package:sete_alegrias_de_maria/data/repositories/historico_repository.dart';

/// Mantém o histórico em memória e grava no celular a cada terço concluído.
class HistoricoController extends Notifier<Historico> {
  HistoricoRepository get _repositorio =>
      ref.read(historicoRepositoryProvider);

  @override
  Historico build() => _repositorio.ler();

  void registrarTercoRezado() {
    final agora = ref.read(relogioProvider)();
    state = state.registrarTerco(agora);
    unawaited(_repositorio.salvar(state));
  }
}

final historicoProvider =
    NotifierProvider<HistoricoController, Historico>(HistoricoController.new);
