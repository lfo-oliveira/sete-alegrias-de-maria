import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/models/passo.dart';
import 'package:sete_alegrias_de_maria/data/repositories/conteudo_repository.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/idioma_controller.dart';
import 'package:sete_alegrias_de_maria/features/terco/application/terco_controller.dart';

/// Pasta padrão onde ficam os MP3 das orações em português.
const pastaDeAudios = 'assets/audio/pt/oracoes';

/// Pasta padrão onde ficam os MP3 das leituras em português.
const pastaDeLeituras = 'assets/audio/pt/leituras';

/// Pasta onde ficam os MP3 das orações para um idioma específico.
String pastaDeAudiosDoIdioma(String idioma) => 'assets/audio/$idioma/oracoes';

/// Pasta onde ficam os MP3 das leituras para um idioma específico.
String pastaDeLeiturasDoIdioma(String idioma) => 'assets/audio/$idioma/leituras';

/// Caminho do MP3 da leitura de uma alegria.
String caminhoDaLeitura(int alegriaId, [String idioma = 'pt']) =>
    '${pastaDeLeiturasDoIdioma(idioma)}/alegria_$alegriaId.mp3';

/// Caminhos de todos os áudios (.mp3) que realmente existem no app sob `assets/audio/`.
/// Assim, oração sem gravação fica sem botão "Ouvir" em vez de dar erro.
final audiosDisponiveisProvider = FutureProvider<Set<String>>((ref) async {
  final manifesto = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifesto
      .listAssets()
      .where(
        (caminho) =>
            caminho.endsWith('.mp3') &&
            caminho.startsWith('assets/audio/'),
      )
      .toSet();
});

/// Conjunto de códigos de idioma (ex.: {'pt'}) que possuem ao menos um arquivo de áudio disponível no app.
final idiomasComAudioProvider = Provider<Set<String>>((ref) {
  final disponiveis = ref.watch(audiosDisponiveisProvider).valueOrNull;
  if (disponiveis == null) return const {};

  final idiomas = <String>{};
  for (final caminho in disponiveis) {
    // Exemplo: 'assets/audio/pt/oracoes/ave_maria.mp3' -> partes: ['assets', 'audio', 'pt', ...]
    final partes = caminho.split('/');
    if (partes.length >= 3 && partes[0] == 'assets' && partes[1] == 'audio') {
      idiomas.add(partes[2]);
    }
  }
  return idiomas;
});

/// Áudio de um passo, ou null se este passo não tem áudio no idioma solicitado.
/// Na meditação é a leitura da alegria. Nas orações, por padrão o arquivo se
/// chama `<id da oração>.mp3` na pasta do idioma correspondente; o campo "audio" do
/// oracoes.json pode indicar outro caminho customizado.
///
/// Função pura: o controlador a usa direto (sem depender da ordem em que o
/// Riverpod atualiza os providers) e o provider abaixo a usa para a tela.
String? caminhoDoAudioDoPasso({
  required Passo passo,
  required Conteudo? conteudo,
  required Set<String>? disponiveis,
  String idioma = 'pt',
}) {
  if (disponiveis == null) return null;

  // Meditação: toca a leitura da alegria (trecho bíblico + reflexão).
  if (passo.tipo == TipoPasso.meditacao) {
    final alegriaId = passo.alegriaId;
    if (alegriaId == null) return null;
    final caminho = caminhoDaLeitura(alegriaId, idioma);
    return disponiveis.contains(caminho) ? caminho : null;
  }

  final id = passo.oracaoId;
  if (id == null || conteudo == null) return null;

  final oracao = conteudo.oracoes[id];
  if (oracao == null) return null;

  final caminhoPadrao = '${pastaDeAudiosDoIdioma(idioma)}/${oracao.id}.mp3';
  final caminho = oracao.audio ?? caminhoPadrao;
  return disponiveis.contains(caminho) ? caminho : null;
}

/// Áudio do passo atual (para a tela), considerando o idioma ativo.
final caminhoDoAudioProvider = Provider<String?>((ref) {
  final passo = ref.watch(tercoControllerProvider.select((s) => s.passoAtual));
  final codigoIdioma = ref.watch(codigoIdiomaProvider);
  return caminhoDoAudioDoPasso(
    passo: passo,
    conteudo: ref.watch(conteudoProvider).valueOrNull,
    disponiveis: ref.watch(audiosDisponiveisProvider).valueOrNull,
    idioma: codigoIdioma,
  );
});
