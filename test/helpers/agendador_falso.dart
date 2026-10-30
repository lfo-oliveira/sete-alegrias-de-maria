import 'package:sete_alegrias_de_maria/features/lembretes/data/agendador_lembretes.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/agenda.dart';

/// Agendador de mentira para os testes: só anota o que foi pedido.
class AgendadorFalso implements AgendadorLembretes {
  AgendadorFalso({this.permitir = true});

  final bool permitir;
  int pedidosDePermissao = 0;
  int consultasDePermissao = 0;
  List<NotificacaoAgendada> agenda = [];

  @override
  Future<bool> pedirPermissao() async {
    pedidosDePermissao++;
    return permitir;
  }

  @override
  Future<bool> permissaoConcedida() async {
    consultasDePermissao++;
    return permitir;
  }

  @override
  Future<void> substituirAgenda(List<NotificacaoAgendada> notificacoes) async {
    agenda = notificacoes;
  }
}
