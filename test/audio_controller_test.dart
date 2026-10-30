import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/data/models/oracao.dart';
import 'package:sete_alegrias_de_maria/data/repositories/conteudo_repository.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/audio/application/audio_controller.dart';
import 'package:sete_alegrias_de_maria/features/audio/application/audios_disponiveis.dart';
import 'package:sete_alegrias_de_maria/features/audio/data/player_audio.dart';
import 'package:sete_alegrias_de_maria/features/terco/application/terco_controller.dart';
import 'package:sete_alegrias_de_maria/features/terco/domain/terco_sequencia.dart';

import 'helpers/player_falso.dart';

const _idsDasOracoes = [
  'sinal_da_cruz',
  'credo',
  'oferecimento',
  'pai_nosso',
  'ave_maria',
  'gloria',
  'salve_rainha',
  'oracao_final',
];

String _mp3(String id) => '$pastaDeAudios/$id.mp3';
String _leitura(int alegria) => caminhoDaLeitura(alegria);

/// Passos do terço (índice): 0 sinal, 1 credo, 2 oferecimento, 3 meditação,
/// 4 pai-nosso, 5 a 14 Ave-Marias, 15 glória ... o último é a Salve Rainha.
class _Cenario {
  _Cenario(this.container, this.player);

  final ProviderContainer container;
  final PlayerFalso player;

  AudioController get audio =>
      container.read(audioControllerProvider.notifier);
  AudioState get estadoAudio => container.read(audioControllerProvider);
  TercoController get terco =>
      container.read(tercoControllerProvider.notifier);
  int get indice => container.read(tercoControllerProvider).indice;
}

Future<_Cenario> _montar({
  Set<String> comAudio = const {
    'sinal_da_cruz',
    'credo',
    'pai_nosso',
    'ave_maria',
    'gloria',
    'oracao_final',
  },
  Set<int> leituras = const {},
  Map<String, Object> salvos = const {},
}) async {
  SharedPreferences.setMockInitialValues(salvos);
  final prefs = await SharedPreferences.getInstance();
  final player = PlayerFalso();

  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    playerAudioProvider.overrideWithValue(player),
    pausaEntreAudiosProvider.overrideWithValue(Duration.zero),
    conteudoProvider.overrideWith(
      (ref) => Conteudo(
        oracoes: {
          for (final id in _idsDasOracoes)
            id: Oracao(id: id, titulo: id, texto: 'texto'),
        },
        alegrias: const {},
      ),
    ),
    audiosDisponiveisProvider.overrideWith(
      (ref) async => {
        for (final id in comAudio) _mp3(id),
        for (final n in leituras) _leitura(n),
      },
    ),
  ]);
  addTearDown(container.dispose);

  await container.read(conteudoProvider.future);
  await container.read(audiosDisponiveisProvider.future);
  // Mantém o controle de áudio vivo (na tela real, o widget faz isso).
  container.listen(audioControllerProvider, (_, __) {});

  return _Cenario(container, player);
}

Future<void> _esperar() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  test('sem nenhum áudio no app, o passo não tem caminho de áudio', () async {
    final c = await _montar(comAudio: const {});
    expect(c.container.read(caminhoDoAudioProvider), isNull);
  });

  test('o passo atual aponta para o MP3 da oração', () async {
    final c = await _montar();
    expect(c.container.read(caminhoDoAudioProvider), _mp3('sinal_da_cruz'));
  });

  test('a meditação aponta para o MP3 da leitura da alegria', () async {
    final c = await _montar(
      comAudio: const {},
      leituras: {1},
      salvos: {'terco.indice_atual': 3}, // meditação da 1ª alegria
    );
    expect(c.container.read(caminhoDoAudioProvider), _leitura(1));
  });

  test('meditação sem leitura gravada não tem caminho de áudio', () async {
    final c = await _montar(
      comAudio: const {},
      leituras: {2}, // só a 2ª alegria tem leitura
      salvos: {'terco.indice_atual': 3}, // meditação da 1ª alegria
    );
    expect(c.container.read(caminhoDoAudioProvider), isNull);
  });

  test('Ouvir na meditação toca a leitura e depois avança para o Pai-Nosso',
      () async {
    final c = await _montar(
      comAudio: const {'pai_nosso'},
      leituras: {1},
      salvos: {'terco.indice_atual': 3},
    );
    await c.audio.alternarTocar();
    expect(c.player.tocados, [_leitura(1)]);

    c.player.terminar();
    await _esperar();

    expect(c.indice, 4);
    expect(c.player.tocados, [_leitura(1), _mp3('pai_nosso')]);
  });

  test('oração sem gravação não tem caminho de áudio', () async {
    final c = await _montar(salvos: {'terco.indice_atual': 2}); // oferecimento
    expect(c.container.read(caminhoDoAudioProvider), isNull);
  });

  test('Ouvir toca o áudio do passo atual', () async {
    final c = await _montar();
    await c.audio.alternarTocar();

    expect(c.player.tocados, [_mp3('sinal_da_cruz')]);
    expect(c.estadoAudio.tocando, isTrue);
  });

  test('ao terminar, avança sozinho e toca o próximo', () async {
    final c = await _montar();
    await c.audio.alternarTocar();

    c.player.terminar();
    await _esperar();

    expect(c.indice, 1);
    expect(c.player.tocados, [_mp3('sinal_da_cruz'), _mp3('credo')]);
    expect(c.estadoAudio.tocando, isTrue);
  });

  test('com avanço automático desligado, não avança ao terminar', () async {
    final c = await _montar();
    c.audio.definirAvancoAutomatico(false);
    await c.audio.alternarTocar();

    c.player.terminar();
    await _esperar();

    expect(c.indice, 0);
    expect(c.estadoAudio.tocando, isFalse);
  });

  test('Pausar para o áudio e não avança', () async {
    final c = await _montar();
    await c.audio.alternarTocar();
    await c.audio.alternarTocar(); // pausa

    expect(c.estadoAudio.tocando, isFalse);
    expect(c.player.pausas, 1);

    c.player.terminar();
    await _esperar();
    expect(c.indice, 0);
  });

  test('Ouvir de novo depois de pausar continua de onde parou', () async {
    final c = await _montar();
    await c.audio.alternarTocar();
    await c.audio.alternarTocar(); // pausa
    await c.audio.alternarTocar(); // continua

    expect(c.player.retomadas, 1);
    expect(c.player.tocados.length, 1); // não recarregou
    expect(c.estadoAudio.tocando, isTrue);
  });

  test('passo sem áudio espera o fiel; ao avançar, o áudio volta sozinho',
      () async {
    final c = await _montar(salvos: {'terco.indice_atual': 1}); // credo
    await c.audio.alternarTocar();

    c.player.terminar(); // credo acabou -> passo 2 (oferecimento, sem áudio)
    await _esperar();
    expect(c.indice, 2);
    expect(c.estadoAudio.tocando, isFalse);

    c.terco.avancar(); // 3: meditação, sem áudio
    await _esperar();
    expect(c.estadoAudio.tocando, isFalse);

    c.terco.avancar(); // 4: Pai-Nosso, com áudio
    await _esperar();
    expect(c.player.tocados.last, _mp3('pai_nosso'));
    expect(c.estadoAudio.tocando, isTrue);
  });

  test('tocar em Próxima durante o áudio troca para o áudio seguinte',
      () async {
    final c = await _montar();
    await c.audio.alternarTocar();

    c.terco.avancar();
    await _esperar();

    expect(c.player.tocados, [_mp3('sinal_da_cruz'), _mp3('credo')]);
    expect(c.player.paradas, greaterThan(0));
  });

  test('sem ter tocado em Ouvir, mudar de passo não toca nada', () async {
    final c = await _montar();
    c.terco.avancar();
    await _esperar();
    expect(c.player.tocados, isEmpty);
  });

  test('no último passo não avança nem tenta concluir sozinho', () async {
    final ultimo = construirTerco().length - 1;
    final c = await _montar(salvos: {'terco.indice_atual': ultimo});
    expect(c.container.read(tercoControllerProvider).ehUltimo, isTrue);
    await c.audio.alternarTocar();

    c.player.terminar();
    await _esperar();

    expect(c.indice, ultimo);
    expect(c.estadoAudio.tocando, isFalse);
  });

  test('áudio com defeito mostra erro e não trava o terço', () async {
    final c = await _montar();
    c.player.falharAoCarregar = true;
    await c.audio.alternarTocar();

    expect(c.estadoAudio.erro, isTrue);
    expect(c.estadoAudio.tocando, isFalse);
    c.terco.avancar();
    expect(c.indice, 1);
  });

  test('a escolha do avanço automático fica salva', () async {
    final c = await _montar();
    c.audio.definirAvancoAutomatico(false);
    await _esperar();

    final prefs = c.container.read(sharedPreferencesProvider);
    expect(prefs.getBool('config.audio_avanco_automatico'), false);
  });

  test('começa com o avanço automático ligado', () async {
    final c = await _montar();
    expect(c.estadoAudio.avancoAutomatico, isTrue);
  });
}
