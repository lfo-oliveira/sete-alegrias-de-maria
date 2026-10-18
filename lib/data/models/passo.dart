/// Tipos de passo que o fiel percorre durante o terço.
enum TipoPasso {
  /// Oração falada/lida (Pai-Nosso, Glória, Credo, Salve Rainha...).
  oracao,

  /// Meditação de uma alegria (trecho bíblico + reflexão).
  meditacao,

  /// Uma Ave-Maria de uma dezena (com contador, ex.: 3 de 10).
  aveMaria,
}

/// Um único passo do terço. É apenas DADO: não toca áudio nem desenha tela.
/// O controlador e as telas é que decidem o que fazer com cada passo.
class Passo {
  const Passo({
    required this.tipo,
    this.oracaoId,
    this.alegriaId,
    this.contador,
    this.total,
  });

  /// Passo de oração simples. [oracaoId] deve existir em oracoes.json.
  const Passo.oracao(String oracaoId, {int? alegriaId})
      : this(tipo: TipoPasso.oracao, oracaoId: oracaoId, alegriaId: alegriaId);

  /// Passo de meditação. [alegriaId] deve existir em alegrias.json.
  const Passo.meditacao(int alegriaId)
      : this(tipo: TipoPasso.meditacao, alegriaId: alegriaId);

  /// Passo de Ave-Maria [contador] de [total].
  const Passo.aveMaria({
    required int contador,
    required int total,
    int? alegriaId,
  }) : this(
          tipo: TipoPasso.aveMaria,
          oracaoId: OracaoIds.aveMaria,
          alegriaId: alegriaId,
          contador: contador,
          total: total,
        );

  final TipoPasso tipo;

  /// Id da oração em oracoes.json (null na meditação).
  final String? oracaoId;

  /// Alegria (1 a 7) a que o passo pertence. Null nas orações iniciais/finais.
  final int? alegriaId;

  /// Número da Ave-Maria atual (1..total). Só para [TipoPasso.aveMaria].
  final int? contador;

  /// Total de Ave-Marias do grupo. Só para [TipoPasso.aveMaria].
  final int? total;

  @override
  String toString() =>
      'Passo($tipo, oracao: $oracaoId, alegria: $alegriaId, $contador/$total)';
}

/// Ids das orações. Devem ser iguais aos ids de assets/content/oracoes.json.
/// Centralizar aqui evita erro de digitação espalhado pelo código.
abstract final class OracaoIds {
  static const sinalDaCruz = 'sinal_da_cruz';
  static const oferecimento = 'oferecimento';
  static const credo = 'credo';
  static const paiNosso = 'pai_nosso';
  static const aveMaria = 'ave_maria';
  static const gloria = 'gloria';
  static const salveRainha = 'salve_rainha';
  static const oracaoFinal = 'oracao_final';
}
