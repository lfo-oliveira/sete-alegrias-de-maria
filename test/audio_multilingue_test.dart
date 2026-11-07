import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/data/models/alegria.dart';
import 'package:sete_alegrias_de_maria/data/models/oracao.dart';
import 'package:sete_alegrias_de_maria/data/models/passo.dart';
import 'package:sete_alegrias_de_maria/data/repositories/conteudo_repository.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/audio/application/audios_disponiveis.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/idioma_controller.dart';

void main() {
  group('Resolução dinâmica de áudios por idioma', () {
    final oracoes = {
      'pai_nosso': const Oracao(id: 'pai_nosso', titulo: 'Pai Nosso', texto: '...'),
      'ave_maria': const Oracao(id: 'ave_maria', titulo: 'Ave Maria', texto: '...'),
    };
    final alegrias = {
      1: const Alegria(
        id: 1,
        titulo: 'Anunciação',
        referencia: 'Lc 1, 26',
        trechoBiblico: '...',
        reflexao: '...',
      ),
    };
    final conteudo = Conteudo(oracoes: oracoes, alegrias: alegrias);

    test('resolve o caminho correto para oração em espanhol quando disponível', () {
      const passo = Passo.oracao('pai_nosso');
      final disponiveis = {
        'assets/audio/es/oracoes/pai_nosso.mp3',
        'assets/audio/pt/oracoes/pai_nosso.mp3',
      };

      final caminho = caminhoDoAudioDoPasso(
        passo: passo,
        conteudo: conteudo,
        disponiveis: disponiveis,
        idioma: 'es',
      );

      expect(caminho, 'assets/audio/es/oracoes/pai_nosso.mp3');
    });

    test('resolve o caminho correto para meditação em latim quando disponível', () {
      const passo = Passo.meditacao(1);
      final disponiveis = {
        'assets/audio/la/leituras/alegria_1.mp3',
        'assets/audio/pt/leituras/alegria_1.mp3',
      };

      final caminho = caminhoDoAudioDoPasso(
        passo: passo,
        conteudo: conteudo,
        disponiveis: disponiveis,
        idioma: 'la',
      );

      expect(caminho, 'assets/audio/la/leituras/alegria_1.mp3');
    });

    test('retorna null se o áudio não estiver gravado no idioma selecionado', () {
      const passo = Passo.oracao('pai_nosso');
      // Apenas português tem o áudio gravado
      final disponiveis = {
        'assets/audio/pt/oracoes/pai_nosso.mp3',
      };

      final caminho = caminhoDoAudioDoPasso(
        passo: passo,
        conteudo: conteudo,
        disponiveis: disponiveis,
        idioma: 'it', // Usuário está rezando em italiano
      );

      // Deve retornar null para que os controles de áudio fiquem ocultos
      expect(caminho, isNull);
    });

    test('retorna null se a meditação não estiver gravada no idioma selecionado', () {
      const passo = Passo.meditacao(1);
      final disponiveis = {
        'assets/audio/pt/leituras/alegria_1.mp3',
      };

      final caminho = caminhoDoAudioDoPasso(
        passo: passo,
        conteudo: conteudo,
        disponiveis: disponiveis,
        idioma: 'en',
      );

      expect(caminho, isNull);
    });
  });

  group('idiomasComAudioProvider', () {
    test('identifica corretamente quais idiomas possuem ao menos um áudio', () async {
      final container = ProviderContainer(
        overrides: [
          audiosDisponiveisProvider.overrideWith(
            (ref) async => {
              'assets/audio/pt/oracoes/ave_maria.mp3',
              'assets/audio/pt/leituras/alegria_1.mp3',
              'assets/audio/es/oracoes/ave_maria.mp3',
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      // Antes do FutureProvider carregar
      expect(container.read(idiomasComAudioProvider), isEmpty);

      // Aguarda carregar
      await container.read(audiosDisponiveisProvider.future);

      final idiomas = container.read(idiomasComAudioProvider);
      expect(idiomas, containsAll(['pt', 'es']));
      expect(idiomas.contains('en'), isFalse);
      expect(idiomas.contains('it'), isFalse);
      expect(idiomas.contains('la'), isFalse);
    });
  });

  group('caminhoDoAudioProvider com troca de idioma', () {
    test('atualiza o áudio do passo quando o idioma do app muda', () async {
      SharedPreferences.setMockInitialValues({'config.idioma': 'pt'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          conteudoProvider.overrideWith(
            (ref) => const Conteudo(
              oracoes: {
                'sinal_da_cruz': Oracao(id: 'sinal_da_cruz', titulo: 'Sinal da Cruz', texto: '...'),
              },
              alegrias: {},
            ),
          ),
          audiosDisponiveisProvider.overrideWith(
            (ref) async => {
              'assets/audio/pt/oracoes/sinal_da_cruz.mp3',
              'assets/audio/es/oracoes/sinal_da_cruz.mp3',
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(audiosDisponiveisProvider.future);

      // Inicialmente em português
      expect(
        container.read(caminhoDoAudioProvider),
        'assets/audio/pt/oracoes/sinal_da_cruz.mp3',
      );

      // Troca para espanhol
      await container.read(idiomaControllerProvider.notifier).definirIdioma(const Locale('es'));

      expect(
        container.read(caminhoDoAudioProvider),
        'assets/audio/es/oracoes/sinal_da_cruz.mp3',
      );

      // Troca para italiano (que ainda não tem o áudio gravado)
      await container.read(idiomaControllerProvider.notifier).definirIdioma(const Locale('it'));

      // Deve ficar null (ocultar player)
      expect(
        container.read(caminhoDoAudioProvider),
        isNull,
      );
    });
  });
}
