import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/models/passo.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/historico/application/historico_controller.dart';
import 'package:sete_alegrias_de_maria/features/terco/domain/terco_sequencia.dart';

/// Estado do terço em andamento: a lista de passos e em qual estamos.
class TercoState {
  const TercoState({required this.passos, this.indice = 0});

  final List<Passo> passos;
  final int indice;

  Passo get passoAtual => passos[indice];
  bool get ehPrimeiro => indice == 0;
  bool get ehUltimo => indice == passos.length - 1;

  /// True se o fiel já avançou no terço (há onde "continuar").
  bool get emAndamento => indice > 0;

  /// De 0.0 a 1.0, para a barra de progresso.
  double get progresso => (indice + 1) / passos.length;

  TercoState copyWith({int? indice}) =>
      TercoState(passos: passos, indice: indice ?? this.indice);

  // <-- ADICIONAR ESTE MÉTODO ABAIXO:
  String get etapaAtual {
    final passo = passoAtual;
    if (passo.alegriaId != null) {
      return '${passo.alegriaId}ª Alegria (de 7)';
    }
    if (indice < 3) {
      return 'Orações iniciais';
    }
    if (ehUltimo || indice >= passos.length - 2) {
      return 'Orações finais';
    }
    return 'Ave-Marias finais';
  }
}

/// Controla a navegação pelos passos do terço e guarda "onde parei".
/// Próximo passo: tocar áudio e avançar sozinho entram AQUI.
class TercoController extends Notifier<TercoState> {
  ProgressoRepository get _progresso => ref.read(progressoRepositoryProvider);

  @override
  TercoState build() {
    final passos = construirTerco();
    final salvo = _progresso.lerIndice();

    // Só aceita o valor salvo se ele ainda existir na lista de passos.
    // (Se a estrutura do terço mudar numa atualização, volta ao início.)
    final valido = salvo != null && salvo >= 0 && salvo < passos.length;
    return TercoState(passos: passos, indice: valido ? salvo : 0);
  }

  void avancar() {
    if (state.ehUltimo) return;
    state = state.copyWith(indice: state.indice + 1);
    _salvar();
  }

  void voltar() {
    if (state.ehPrimeiro) return;
    state = state.copyWith(indice: state.indice - 1);
    _salvar();
  }

  /// Volta ao início e apaga o que estava salvo ("Começar de novo").
  void reiniciar() {
    state = state.copyWith(indice: 0);
    unawaited(_progresso.limpar());
  }

  /// Terço terminado: soma no histórico e zera o progresso salvo.
  void concluir() {
    ref.read(historicoProvider.notifier).registrarTercoRezado();
    reiniciar();
  }

  void _salvar() => unawaited(_progresso.salvarIndice(state.indice));
}

final tercoControllerProvider =
    NotifierProvider<TercoController, TercoState>(TercoController.new);
