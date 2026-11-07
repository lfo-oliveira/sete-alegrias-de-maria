// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get tituloApp => 'Sette Gioie di Maria Santissima';

  @override
  String get subtituloApp => 'Rosario della Corona Francescana';

  @override
  String get rezarTerco => 'Recitare la Corona';

  @override
  String get continuarOndeParei => 'Riprendi da dove avevi interrotto';

  @override
  String get comecarDeNovo => 'Ricomincia da capo';

  @override
  String get parouNasOracoes => 'Ti sei fermato alle preghiere.';

  @override
  String parouNaAlegria(int alegria) {
    return 'Ti sei fermato alla $alegriaª gioia.';
  }

  @override
  String get dialogRecomecarTitulo => 'Ricominciare da capo?';

  @override
  String get dialogRecomecarConteudo =>
      'Il progresso salvato verrà cancellato e tornerai all\'inizio.';

  @override
  String get cancelar => 'Annulla';

  @override
  String get recomecar => 'Ricomincia';

  @override
  String get voltar => 'Indietro';

  @override
  String get proxima => 'Avanti';

  @override
  String get concluir => 'Termina';

  @override
  String get tercoConcluidoMensagem => 'Corona completata. Dio ti benedica! 🙏';

  @override
  String erroCarregarOracoes(String erro) {
    return 'Impossibile caricare le preghiere.\n$erro';
  }

  @override
  String aveMariaContador(int atual, int total) {
    return 'Ave Maria $atual di $total';
  }

  @override
  String get ouvir => 'Ascolta';

  @override
  String get pausar => 'Pausa';

  @override
  String get avancoAutomatico => 'Avanzamento automatico';

  @override
  String get audioDisponivel => 'Audio disponibile';

  @override
  String get erroTocarAudio => 'Impossibile riprodurre questo audio.';

  @override
  String velocidadeAudio(String velocidade) {
    return 'Velocità audio: $velocidade';
  }

  @override
  String get lembretes => 'Promemoria';

  @override
  String get backup => 'Copia di backup';

  @override
  String get tamanhoLetra => 'Dimensione del testo';

  @override
  String get temaDoApp => 'Tema dell\'applicazione';

  @override
  String get temaClaro => 'Chiaro';

  @override
  String get temaEscuro => 'Scuro';

  @override
  String get temaSistema => 'Automatico';

  @override
  String get vibracaoAtivada => 'Vibrazione attivata';

  @override
  String get vibracaoDesativada => 'Vibrazione disattivata';

  @override
  String get tercosRezados => 'Rosari recitati';

  @override
  String get diasSeguidos => 'Giorni consecutivi';

  @override
  String get estaSemana => 'Questa settimana';

  @override
  String get compartilhar => 'Condividi';

  @override
  String get fechar => 'Chiudi';

  @override
  String get confirmar => 'Conferma';
}
