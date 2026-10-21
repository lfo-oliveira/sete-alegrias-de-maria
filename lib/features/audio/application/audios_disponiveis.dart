import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/models/passo.dart';
import 'package:sete_alegrias_de_maria/data/repositories/conteudo_repository.dart';
import 'package:sete_alegrias_de_maria/features/terco/application/terco_controller.dart';

/// Pasta onde ficam os MP3 das orações.
const pastaDeAudios = 'assets/audio/oracoes';

/// Pasta onde ficam os MP3 das leituras (trecho bíblico + reflexão), um por
/// alegria: `alegria_1.mp3` até `alegria_7.mp3`.
const pastaDeLeituras = 'assets/audio/leituras';

/// Caminho do MP3 da leitura de uma alegria.
String caminhoDaLeitura(int alegriaId) =>
    '$pastaDeLeituras/alegria_$alegriaId.mp3';

/// Caminhos dos áudios que realmente existem no app.
/// Assim, oração sem gravação fica sem botão "Ouvir" em vez de dar erro.
final audiosDisponiveisProvider = FutureProvider<Set<String>>((ref) async {
  final manifesto = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifesto
      .listAssets()
      .where(
        (caminho) =>
            caminho.endsWith('.mp3') &&
            (caminho.startsWith('$pastaDeAudios/') ||
                caminho.startsWith('$pastaDeLeituras/')),
      )
      .toSet();
});

/// Áudio de um passo, ou null se este passo não tem áudio.
/// Na meditação é a leitura da alegria. Nas orações, por padrão o arquivo se
/// chama `<id da oração>.mp3`; o campo "audio" do oracoes.json pode indicar
/// outro caminho.
///
/// Função pura: o controlador a usa direto (sem depender da ordem em que o
/// Riverpod atualiza os providers) e o provider abaixo a usa para a tela.
String? caminhoDoAudioDoPasso({
  required Passo passo,
  required Conteudo? conteudo,
  required Set<String>? disponiveis,
}) {
  if (disponiveis == null) return null;

  // Meditação: toca a leitura da alegria (trecho bíblico + reflexão).
  if (passo.tipo == TipoPasso.meditacao) {
    final alegriaId = passo.alegriaId;
    if (alegriaId == null) return null;
    final caminho = caminhoDaLeitura(alegriaId);
    return disponiveis.contains(caminho) ? caminho : null;
  }

  final id = passo.oracaoId;
  if (id == null || conteudo == null) return null;

  final oracao = conteudo.oracoes[id];
  if (oracao == null) return null;

  final caminho = oracao.audio ?? '$pastaDeAudios/${oracao.id}.mp3';
  return disponiveis.contains(caminho) ? caminho : null;
}

/// Áudio do passo atual (para a tela).
final caminhoDoAudioProvider = Provider<String?>((ref) {
  final passo = ref.watch(tercoControllerProvider.select((s) => s.passoAtual));
  return caminhoDoAudioDoPasso(
    passo: passo,
    conteudo: ref.watch(conteudoProvider).valueOrNull,
    disponiveis: ref.watch(audiosDisponiveisProvider).valueOrNull,
  );
});
