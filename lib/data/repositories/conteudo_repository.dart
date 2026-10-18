import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/models/alegria.dart';
import 'package:sete_alegrias_de_maria/data/models/oracao.dart';

/// Todo o conteúdo de texto do app, já carregado e indexado por id.
class Conteudo {
  const Conteudo({required this.oracoes, required this.alegrias});

  final Map<String, Oracao> oracoes;
  final Map<int, Alegria> alegrias;
}

/// Lê os textos dos arquivos JSON em assets/content/.
/// Para atualizar textos, edite os JSON: não precisa mexer no código.
class ConteudoRepository {
  static const _caminhoOracoes = 'assets/content/oracoes.json';
  static const _caminhoAlegrias = 'assets/content/alegrias.json';

  Future<Conteudo> carregar() async {
    final oracoesJson = await _lerJson(_caminhoOracoes);
    final alegriasJson = await _lerJson(_caminhoAlegrias);

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

  Future<Map<String, dynamic>> _lerJson(String caminho) async {
    final texto = await rootBundle.loadString(caminho);
    return jsonDecode(texto) as Map<String, dynamic>;
  }
}

final conteudoRepositoryProvider = Provider<ConteudoRepository>(
  (ref) => ConteudoRepository(),
);

/// Carrega o conteúdo uma vez e guarda em memória.
final conteudoProvider = FutureProvider<Conteudo>(
  (ref) => ref.watch(conteudoRepositoryProvider).carregar(),
);
