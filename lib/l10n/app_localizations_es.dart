// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get tituloApp => 'Siete Alegrías de Nuestra Señora';

  @override
  String get subtituloApp => 'Rosario de la Corona Franciscana';

  @override
  String get rezarTerco => 'Rezar la Corona';

  @override
  String get continuarOndeParei => 'Continuar donde lo dejé';

  @override
  String get comecarDeNovo => 'Comenzar de nuevo';

  @override
  String get parouNasOracoes => 'Te quedaste en las oraciones.';

  @override
  String parouNaAlegria(int alegria) {
    return 'Te quedaste en la $alegriaª alegría.';
  }

  @override
  String get dialogRecomecarTitulo => '¿Comenzar de nuevo?';

  @override
  String get dialogRecomecarConteudo =>
      'El progreso guardado se borrará y volverás al inicio.';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get recomecar => 'Comenzar de nuevo';

  @override
  String get voltar => 'Atrás';

  @override
  String get proxima => 'Siguiente';

  @override
  String get concluir => 'Finalizar';

  @override
  String get tercoConcluidoMensagem =>
      'Corona concluida. ¡Que Dios te bendiga! 🙏';

  @override
  String erroCarregarOracoes(String erro) {
    return 'No se pudieron cargar las oraciones.\n$erro';
  }

  @override
  String aveMariaContador(int atual, int total) {
    return 'Avemaría $atual de $total';
  }

  @override
  String get ouvir => 'Escuchar';

  @override
  String get pausar => 'Pausar';

  @override
  String get avancoAutomatico => 'Avance automático';

  @override
  String get erroTocarAudio => 'No fue posible reproducir este audio.';

  @override
  String velocidadeAudio(String velocidade) {
    return 'Velocidad de reproducción: $velocidade';
  }

  @override
  String get lembretes => 'Recordatorios';

  @override
  String get backup => 'Copia de seguridad';

  @override
  String get tamanhoLetra => 'Tamaño de letra';

  @override
  String get temaDoApp => 'Tema de la aplicación';

  @override
  String get temaClaro => 'Claro';

  @override
  String get temaEscuro => 'Oscuro';

  @override
  String get temaSistema => 'Automático';

  @override
  String get vibracaoAtivada => 'Vibración activada';

  @override
  String get vibracaoDesativada => 'Vibración desactivada';

  @override
  String get tercosRezados => 'Rosarios rezados';

  @override
  String get diasSeguidos => 'Días seguidos';

  @override
  String get estaSemana => 'Esta semana';

  @override
  String get compartilhar => 'Compartir';

  @override
  String get fechar => 'Cerrar';

  @override
  String get confirmar => 'Confirmar';
}
