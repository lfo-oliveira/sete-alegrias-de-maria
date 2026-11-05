import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/repositories/configuracoes_repository.dart';
import 'package:sete_alegrias_de_maria/data/repositories/conteudo_repository.dart';
import 'package:sete_alegrias_de_maria/features/audio/application/audios_disponiveis.dart';
import 'package:sete_alegrias_de_maria/features/audio/data/player_audio.dart';
import 'package:sete_alegrias_de_maria/features/terco/application/terco_controller.dart';

class AudioState {
  const AudioState({
    this.tocando = false,
    this.avancoAutomatico = true,
    this.erro = false,
    this.velocidade = 1.0, // Construtor
  });

  /// Há um áudio tocando agora.
  final bool tocando;

  /// Quando o áudio acaba, passa sozinho para o próximo passo.
  final bool avancoAutomatico;

  /// O último áudio não pôde ser tocado.
  final bool erro;

  // <-- ADICIONAR ESTA LINHA ABAIXO:
  final double velocidade;

  AudioState copyWith({
    bool? tocando,
    bool? avancoAutomatico,
    bool? erro,
    double? velocidade,
  }) =>
      AudioState(
        tocando: tocando ?? this.tocando,
        avancoAutomatico: avancoAutomatico ?? this.avancoAutomatico,
        erro: erro ?? this.erro,
        velocidade: velocidade ?? this.velocidade,
      );
}

/// Pausa entre uma oração e a próxima no avanço automático.
/// Os testes trocam por Duration.zero.
final pausaEntreAudiosProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 700),
);

/// Toca o áudio de cada passo e, se o fiel quiser, avança sozinho.
///
/// Como funciona: o fiel toca em "Ouvir" uma vez e isso abre uma "sessão de
/// áudio". Enquanto a sessão estiver aberta, cada passo que tem áudio toca
/// assim que o fiel chega nele (sozinho, ou ao tocar em Próxima). Passos sem
/// áudio (como a meditação) esperam o fiel ler e tocar em Próxima.
/// "Pausar" fecha a sessão.
///
/// É autoDispose: some quando a tela do terço fecha, e o áudio para junto.
class AudioController extends AutoDisposeNotifier<AudioState> {
  late PlayerAudio _player;
  bool _sessao = false;
  String? _carregado;

  /// Número da "rodada" atual. Cada mudança invalida avanços e carregamentos
  /// que ainda estavam pendentes (ex.: o fiel tocou em Próxima na pausa).
  int _rodada = 0;

  @override
  AudioState build() {
    _player = ref.watch(playerAudioProvider);
    final assinatura = _player.fim.listen((_) => _aoTerminar());
    ref.onDispose(() {
      assinatura.cancel();
      _rodada++;
    });

    ref.listen<int>(
      tercoControllerProvider.select((s) => s.indice),
      _aoMudarDePasso,
    );

    return AudioState(
      avancoAutomatico:
          ref.read(configuracoesRepositoryProvider).lerAvancoAutomatico(),
    );
  }

  /// Áudio do passo atual, lido direto do estado do terço (sempre atualizado,
  /// mesmo dentro do aviso de "mudou de passo").
  String? _caminhoAtual() => caminhoDoAudioDoPasso(
        passo: ref.read(tercoControllerProvider).passoAtual,
        conteudo: ref.read(conteudoProvider).valueOrNull,
        disponiveis: ref.read(audiosDisponiveisProvider).valueOrNull,
      );

  /// Botão Ouvir / Pausar.
  Future<void> alternarTocar() async {
    if (state.tocando) {
      _sessao = false;
      _rodada++;
      await _player.pausar();
      state = state.copyWith(tocando: false);
      return;
    }

    _sessao = true;
    final caminho = _caminhoAtual();
    if (caminho == null) return;

    if (_carregado == caminho) {
      // Estava pausado no meio: continua de onde parou.
      state = state.copyWith(tocando: true, erro: false);
      await _player.retomar();
    } else {
      await _tocarPassoAtual();
    }
  }

  // MÉTODO DO AVANÇO AUTOMÁTICO (QUE HAVIA SIDO APAGADO):
  void definirAvancoAutomatico(bool valor) {
    if (valor == state.avancoAutomatico) return;
    state = state.copyWith(avancoAutomatico: valor);
    unawaited(
      ref.read(configuracoesRepositoryProvider).salvarAvancoAutomatico(valor),
    );
  }

  Future<void> definirVelocidade(double valor) async {
    if (valor == state.velocidade) return;
    state = state.copyWith(velocidade: valor);
    await _player.definirVelocidade(valor);
  }


  Future<void> _tocarPassoAtual() async {
    final caminho = _caminhoAtual();
    if (caminho == null) {
      // Passo sem áudio: espera o fiel. A sessão continua aberta.
      state = state.copyWith(tocando: false);
      return;
    }

    final minhaRodada = ++_rodada;
    try {
      await _player.definirVelocidade(state.velocidade); 
      await _player.carregarETocar(caminho);
      if (minhaRodada != _rodada) {
        await _player.parar(); // o fiel já mudou de passo
        return;
      }
      _carregado = caminho;
      state = state.copyWith(tocando: true, erro: false);
    } catch (_) {
      if (minhaRodada != _rodada) return;
      _sessao = false;
      state = state.copyWith(tocando: false, erro: true);
    }
  }

  void _aoMudarDePasso(int? antes, int depois) {
    _rodada++;
    _carregado = null;
    unawaited(_player.parar());
    if (state.tocando) state = state.copyWith(tocando: false);

    final passoAPasso = antes != null && (depois - antes).abs() == 1;
    if (!passoAPasso) {
      // Salto (ex.: terço concluído ou reiniciado): encerra a sessão.
      _sessao = false;
      return;
    }
    if (_sessao) unawaited(_tocarPassoAtual());
  }

  void _aoTerminar() {
    _carregado = null;
    state = state.copyWith(tocando: false);
    if (!_sessao) return;

    final terco = ref.read(tercoControllerProvider);
    if (terco.ehUltimo) {
      _sessao = false; // fim do terço: quem conclui é o fiel
      return;
    }
    if (!state.avancoAutomatico) return;

    final minhaRodada = ++_rodada;
    Future<void>.delayed(ref.read(pausaEntreAudiosProvider)).then((_) {
      if (minhaRodada != _rodada) return;
      ref.read(tercoControllerProvider.notifier).avancar();
    });
  }
}

final audioControllerProvider =
    NotifierProvider.autoDispose<AudioController, AudioState>(
  AudioController.new,
);
