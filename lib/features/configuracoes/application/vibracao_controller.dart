import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/repositories/configuracoes_repository.dart';

/// Controla se a vibração (feedback tátil) nas contas do terço está ativa.
class VibracaoController extends Notifier<bool> {
  ConfiguracoesRepository get _config =>
      ref.read(configuracoesRepositoryProvider);

  @override
  bool build() => _config.lerVibracao();

  void alternar() => definir(!state);

  void definir(bool valor) {
    if (valor == state) return;
    state = valor;
    unawaited(_config.salvarVibracao(valor));
  }
}

final vibracaoProvider = NotifierProvider<VibracaoController, bool>(
  VibracaoController.new,
);