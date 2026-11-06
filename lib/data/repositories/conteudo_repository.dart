import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/models/alegria.dart';
import 'package:sete_alegrias_de_maria/data/models/oracao.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/idioma_controller.dart';

/// Todo o conteúdo de texto do app, já carregado e indexado por id.
class Conteudo {
  const Conteudo({required this.oracoes, required this.alegrias});

  final Map<String, Oracao> oracoes;
  final Map<int, Alegria> alegrias;
}

/// Lê os textos dos arquivos JSON em assets/content/<idioma>/.
/// Se o idioma solicitado não tiver o arquivo, faz fallback automático para 'pt'.
class ConteudoRepository {
  static const idiomaPadrao = 'pt';

  Future<Conteudo> carregar([String idioma = idiomaPadrao]) async {
    final oracoesJson = await _lerJsonSeguro(idioma, 'oracoes.json');
    final alegriasJson = await _lerJsonSeguro(idioma, 'alegrias.json');

    final oracoes = <String, Oracao>{
      for (final item in oracoesJson['oracoes'] as List<dynamic>)
        (item as Map<String, dynamic>)['id'] as String: Oracao.fromJson(item),
    };

    final alegrias = <int, Alegria>{
      for (final item in alegriasJson['alegrias'] as List<dynamic>)
        (item as Map<String, dynamic>)['id'] as int: Alegria.fromJson(item),
    };

    return Conteudo(oracoes: oracoes, alegrias: alegrias);
  }

  Future<Map<String, dynamic>> _lerJsonSeguro(
    String idioma,
    String arquivo,
  ) async {
    try {
      return await _lerJson('assets/content/$idioma/$arquivo');
    } catch (_) {
      // Se não existir o arquivo no idioma solicitado, usa o português como fallback.
      if (idioma != idiomaPadrao) {
        return await _lerJson('assets/content/$idiomaPadrao/$arquivo');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _lerJson(String caminho) async {
    final texto = await rootBundle.loadString(caminho);
    return jsonDecode(texto) as Map<String, dynamic>;
  }
}

final conteudoRepositoryProvider = Provider<ConteudoRepository>(
  (ref) => ConteudoRepository(),
);

/// Carrega o conteúdo conforme o idioma selecionado e guarda em memória.
final conteudoProvider = FutureProvider<Conteudo>((ref) {
  final codigoIdioma = ref.watch(codigoIdiomaProvider);
  return ref.watch(conteudoRepositoryProvider).carregar(codigoIdioma);
});
