import 'package:sete_alegrias_de_maria/features/lembretes/domain/dias_semana.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembrete.dart';

/// Lembretes criados pelo fiel para rezar o terço inteiro.
/// Para mudar as mensagens, é só editar a lista abaixo.
class LembretesTerco {
  static const titulo = 'Hora do terço';

  static const mensagens = [
    'Chegou a hora do seu terço. Reserve alguns minutos para rezar com '
        'Maria. 🙏',
    'Maria te espera: que tal rezar hoje o terço das Sete Alegrias?',
    'Um momento de paz para você: vamos rezar o terço agora?',
    'Que as alegrias de Maria encham o seu dia. Vamos rezar o terço?',
    'Seu terço está esperando. Poucos minutos de oração fazem bem ao '
        'coração.',
    'Reze o terço com calma e confie a Maria o que está no seu coração.',
    'Hora de rezar o terço. Deus te abençoe!',
  ];

  /// Monta um lembrete criado pelo fiel.
  static Lembrete criar({
    required int id,
    required int hora,
    required int minuto,
    required Set<int> dias,
    bool ativo = true,
  }) =>
      Lembrete(
        id: id,
        hora: hora,
        minuto: minuto,
        titulo: titulo,
        descricao: descreverDias(dias),
        mensagens: mensagens,
        dias: dias,
        ativo: ativo,
      );
}
