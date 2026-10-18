import 'package:sete_alegrias_de_maria/data/models/passo.dart';

/// Configuração do terço: TODOS os números e orações fixas ficam aqui.
/// Para mudar a estrutura do terço (ex.: tirar o Credo, mudar a ordem das
/// orações finais), edite apenas este arquivo.
abstract final class TercoConfig {
  /// Quantidade de alegrias (dezenas) do terço.
  static const totalAlegrias = 7;

  /// Ave-Marias em cada dezena.
  static const aveMariasPorDezena = 10;

  /// Ave-Marias extras ao final (tradição das 72 Ave-Marias: 70 + 2).
  static const aveMariasExtras = 2;

  /// Orações rezadas antes da primeira alegria, na ordem.
  static const oracoesIniciais = <String>[
    OracaoIds.sinalDaCruz,
    OracaoIds.credo,
    OracaoIds.oferecimento,
  ];

  /// Orações rezadas depois das Ave-Marias extras, na ordem.
  static const oracoesFinais = <String>[
    OracaoIds.salveRainha,
    OracaoIds.oracaoFinal,
  ];

  /// Total de Ave-Marias esperado no terço completo (72).
  static const totalAveMarias =
      totalAlegrias * aveMariasPorDezena + aveMariasExtras;
}
