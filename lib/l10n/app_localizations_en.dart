// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tituloApp => 'Seven Joys of Our Lady';

  @override
  String get subtituloApp => 'The Franciscan Crown Rosary';

  @override
  String get rezarTerco => 'Pray the Rosary';

  @override
  String get continuarOndeParei => 'Resume where I left off';

  @override
  String get comecarDeNovo => 'Start over';

  @override
  String get parouNasOracoes => 'You paused during the prayers.';

  @override
  String parouNaAlegria(int alegria) {
    return 'You paused at the ${alegria}th Joy.';
  }

  @override
  String get dialogRecomecarTitulo => 'Start over?';

  @override
  String get dialogRecomecarConteudo =>
      'Your saved progress will be cleared and you will return to the beginning.';

  @override
  String get cancelar => 'Cancel';

  @override
  String get recomecar => 'Start over';

  @override
  String get voltar => 'Back';

  @override
  String get proxima => 'Next';

  @override
  String get concluir => 'Finish';

  @override
  String get tercoConcluidoMensagem =>
      'Rosary completed. May God bless you! 🙏';

  @override
  String erroCarregarOracoes(String erro) {
    return 'Could not load prayers.\n$erro';
  }

  @override
  String aveMariaContador(int atual, int total) {
    return 'Hail Mary $atual of $total';
  }

  @override
  String get ouvir => 'Listen';

  @override
  String get pausar => 'Pause';

  @override
  String get avancoAutomatico => 'Auto-advance';

  @override
  String get audioDisponivel => 'Audio available';

  @override
  String get erroTocarAudio => 'Could not play this audio.';

  @override
  String velocidadeAudio(String velocidade) {
    return 'Audio speed: $velocidade';
  }

  @override
  String get lembretes => 'Reminders';

  @override
  String get backup => 'Backup';

  @override
  String get tamanhoLetra => 'Font size';

  @override
  String get temaDoApp => 'App theme';

  @override
  String get temaClaro => 'Light';

  @override
  String get temaEscuro => 'Dark';

  @override
  String get temaSistema => 'Automatic';

  @override
  String get vibracaoAtivada => 'Haptic feedback enabled';

  @override
  String get vibracaoDesativada => 'Haptic feedback disabled';

  @override
  String get tercosRezados => 'Rosaries prayed';

  @override
  String get diasSeguidos => 'Streak days';

  @override
  String get estaSemana => 'This week';

  @override
  String get compartilhar => 'Share';

  @override
  String get fechar => 'Close';

  @override
  String get confirmar => 'Confirm';
}
