import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Toca um áudio por vez. É uma interface para que os testes usem um
/// player falso, sem som e sem celular.
abstract class PlayerAudio {
  /// Avisa quando o áudio chegou ao fim.
  Stream<void> get fim;

  /// Carrega o áudio do início e começa a tocar.
  Future<void> carregarETocar(String caminhoDoAsset);

  /// Continua de onde pausou.
  Future<void> retomar();

  Future<void> pausar();

  Future<void> parar();

  Future<void> liberar();
}

/// Um player novo para cada vez que a tela do terço abre,
/// liberado quando ela fecha.
final playerAudioProvider = Provider.autoDispose<PlayerAudio>((ref) {
  final player = PlayerAudioReal();
  ref.onDispose(player.liberar);
  return player;
});

/// Versão real, com o pacote just_audio.
class PlayerAudioReal implements PlayerAudio {
  final AudioPlayer _player = AudioPlayer();

  @override
  Stream<void> get fim => _player.processingStateStream
      .where((estado) => estado == ProcessingState.completed);

  @override
  Future<void> carregarETocar(String caminhoDoAsset) async {
    await _player.setAsset(caminhoDoAsset);
    // play() só termina quando o áudio acaba; não esperamos aqui.
    unawaited(_player.play());
  }

  @override
  Future<void> retomar() async {
    unawaited(_player.play());
  }

  @override
  Future<void> pausar() => _player.pause();

  @override
  Future<void> parar() => _player.stop();

  @override
  Future<void> liberar() => _player.dispose();
}
