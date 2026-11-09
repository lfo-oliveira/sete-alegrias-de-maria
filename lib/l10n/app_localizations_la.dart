// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latin (`la`).
class AppLocalizationsLa extends AppLocalizations {
  AppLocalizationsLa([String locale = 'la']) : super(locale);

  @override
  String get tituloApp => 'Septem Gaudia Beatæ Mariæ Virginis';

  @override
  String get subtituloApp => 'Corona Franciscana';

  @override
  String get rezarTerco => 'Coronam Recitare';

  @override
  String get continuarOndeParei => 'Continuare ubi destiti';

  @override
  String get comecarDeNovo => 'De novo incipere';

  @override
  String get parouNasOracoes => 'In orationibus mansisti.';

  @override
  String parouNaAlegria(int alegria) {
    return 'In $alegriaº Gaudio mansisti.';
  }

  @override
  String get dialogRecomecarTitulo => 'De novo incipere?';

  @override
  String get dialogRecomecarConteudo =>
      'Progressus servatus delebitur et ad initium reverteris.';

  @override
  String get cancelar => 'Cancellare';

  @override
  String get recomecar => 'De novo incipere';

  @override
  String get voltar => 'Retro';

  @override
  String get proxima => 'Sequens';

  @override
  String get concluir => 'Finis';

  @override
  String get tercoConcluidoMensagem => 'Corona peracta. Deus te benedicat! 🙏';

  @override
  String erroCarregarOracoes(String erro) {
    return 'Orationes legi non potuerunt.\n$erro';
  }

  @override
  String aveMariaContador(int atual, int total) {
    return 'Ave Maria $atual ex $total';
  }

  @override
  String get ouvir => 'Audire';

  @override
  String get pausar => 'Pausa';

  @override
  String get avancoAutomatico => 'Progressus automaticus';

  @override
  String get audioDisponivel => 'Sonus promptus';

  @override
  String get erroTocarAudio => 'Hoc sonum agere non potuit.';

  @override
  String velocidadeAudio(String velocidade) {
    return 'Velocitas: $velocidade';
  }

  @override
  String get lembretes => 'Monitiones';

  @override
  String get backup => 'Copia salutis';

  @override
  String get tamanhoLetra => 'Magnitudo litterarum';

  @override
  String get temaDoApp => 'Forma app';

  @override
  String get temaClaro => 'Lux';

  @override
  String get temaEscuro => 'Nox';

  @override
  String get temaSistema => 'Automata';

  @override
  String get vibracaoAtivada => 'Vibratio actuosa';

  @override
  String get vibracaoDesativada => 'Vibratio inactiva';

  @override
  String get tercosRezados => 'Rosaria recitata';

  @override
  String get diasSeguidos => 'Dies continui';

  @override
  String get estaSemana => 'Hac hebdomada';

  @override
  String get compartilhar => 'Communicare';

  @override
  String get fechar => 'Claudere';

  @override
  String get confirmar => 'Confirmare';
}
