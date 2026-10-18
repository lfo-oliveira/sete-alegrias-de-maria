import 'package:sete_alegrias_de_maria/data/models/historico.dart';

/// Mensagem que acompanha o histórico na tela inicial.
/// Regra do app: INCENTIVAR, nunca cobrar. Para mudar os textos,
/// edite apenas este arquivo.
String mensagemHistorico(Historico historico, DateTime agora) {
  if (historico.tercosRezados == 0) {
    return 'Maria te espera. Que tal rezar o primeiro terço?';
  }
  if (historico.rezouHoje(agora)) {
    return 'Hoje você já rezou com Maria. Deus te abençoe!';
  }
  if (historico.rezouOntem(agora)) {
    return 'Você rezou ontem. Que tal rezar com Maria hoje também?';
  }
  return 'Maria te espera de braços abertos.';
}
