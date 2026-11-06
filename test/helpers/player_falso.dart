import 'dart:async';

import 'package:sete_alegrias_de_maria/features/audio/data/player_audio.dart';

/// Player de mentira: não toca nada, só anota o que foi pedido.
class PlayerFalso implements PlayerAudio {
  final StreamController<void> _fim = StreamController<void>.broadcast();

  final List<String> tocados = [];
  int pausas = 0;
  int retomadas = 0;
  int paradas = 0;
  bool falharAoCarregar = false;
  double velocidadeAtual = 1.0;

  @override
  Stream<void> get fim => _fim.stream;

  /// Simula o áudio chegando ao fim.
  void terminar() => _fim.add(null);

  @override
  Future<void> carregarETocar(String caminhoDoAsset) async {
    if (falharAoCarregar) throw StateError('arquivo com defeito');
    tocados.add(caminhoDoAsset);
  }

  @override
  Future<void> retomar() async => retomadas++;

  @override
  Future<void> pausar() async => pausas++;

  @override
  Future<void> parar() async => paradas++;

  @override
  Future<void> definirVelocidade(double velocidade) async {
    velocidadeAtual = velocidade;
  }

  @override
  Future<void> liberar() async {}

}
