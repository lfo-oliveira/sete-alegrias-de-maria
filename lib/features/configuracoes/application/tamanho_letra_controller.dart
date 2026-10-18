import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/models/tamanho_letra.dart';
import 'package:sete_alegrias_de_maria/data/repositories/configuracoes_repository.dart';

/// Tamanho de letra atual. Começa com o que o fiel escolheu da última vez.
class TamanhoLetraController extends Notifier<TamanhoLetra> {
  ConfiguracoesRepository get _config =>
      ref.read(configuracoesRepositoryProvider);

  @override
  TamanhoLetra build() => _config.lerTamanhoLetra();

  void definir(TamanhoLetra tamanho) {
    if (tamanho == state) return;
    state = tamanho;
    unawaited(_config.salvarTamanhoLetra(tamanho));
  }
}

final tamanhoLetraProvider =
    NotifierProvider<TamanhoLetraController, TamanhoLetra>(
  TamanhoLetraController.new,
);
