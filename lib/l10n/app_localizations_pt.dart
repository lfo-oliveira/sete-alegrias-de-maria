// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get tituloApp => 'Sete Alegrias de Nossa Senhora';

  @override
  String get subtituloApp => 'Terço da Coroa Franciscana';

  @override
  String get rezarTerco => 'Rezar o terço';

  @override
  String get continuarOndeParei => 'Continuar de onde parei';

  @override
  String get comecarDeNovo => 'Começar de novo';

  @override
  String get parouNasOracoes => 'Você parou nas orações.';

  @override
  String parouNaAlegria(int alegria) {
    return 'Você parou na $alegriaª alegria.';
  }

  @override
  String get dialogRecomecarTitulo => 'Recomeçar o terço?';

  @override
  String get dialogRecomecarConteudo =>
      'O progresso salvo até aqui será apagado e você voltará ao início.';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get recomecar => 'Recomeçar';

  @override
  String get voltar => 'Voltar';

  @override
  String get proxima => 'Próxima';

  @override
  String get concluir => 'Concluir';

  @override
  String get tercoConcluidoMensagem => 'Terço concluído. Deus te abençoe! 🙏';

  @override
  String erroCarregarOracoes(String erro) {
    return 'Não foi possível carregar as orações.\n$erro';
  }

  @override
  String aveMariaContador(int atual, int total) {
    return 'Ave-Maria $atual de $total';
  }

  @override
  String get ouvir => 'Ouvir';

  @override
  String get pausar => 'Pausar';

  @override
  String get avancoAutomatico => 'Avanço automático';

  @override
  String get audioDisponivel => 'Áudio disponível';

  @override
  String get erroTocarAudio => 'Não foi possível tocar este áudio.';

  @override
  String velocidadeAudio(String velocidade) {
    return 'Velocidade do áudio: $velocidade';
  }

  @override
  String get lembretes => 'Lembretes';

  @override
  String get backup => 'Backup';

  @override
  String get tamanhoLetra => 'Tamanho da letra';

  @override
  String get temaDoApp => 'Tema do aplicativo';

  @override
  String get temaClaro => 'Claro';

  @override
  String get temaEscuro => 'Escuro';

  @override
  String get temaSistema => 'Automático';

  @override
  String get vibracaoAtivada => 'Vibração ativada';

  @override
  String get vibracaoDesativada => 'Vibração desativada';

  @override
  String get tercosRezados => 'Terços rezados';

  @override
  String get diasSeguidos => 'Dias seguidos';

  @override
  String get estaSemana => 'Esta semana';

  @override
  String get compartilhar => 'Compartilhar';

  @override
  String get fechar => 'Fechar';

  @override
  String get confirmar => 'Confirmar';
}
