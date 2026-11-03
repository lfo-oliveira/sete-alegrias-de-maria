import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz; // <-- Import dos fusos
import 'package:timezone/timezone.dart' as tz;
import 'package:sete_alegrias_de_maria/features/lembretes/domain/agenda.dart';

/// Quem agenda as notificações no celular.
/// É uma interface para que os testes usem uma versão falsa.
abstract class AgendadorLembretes {
  /// Pede permissão de notificação. Devolve true se o fiel permitiu.
  Future<bool> pedirPermissao();

  /// Troca tudo o que estava agendado por [notificacoes].
  Future<void> substituirAgenda(List<NotificacaoAgendada> notificacoes);
}

final agendadorLembretesProvider = Provider<AgendadorLembretes>(
  (ref) => AgendadorLocal(),
);

/// Versão real, com o plugin flutter_local_notifications.
class AgendadorLocal implements AgendadorLembretes {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _iniciado = false;

  static const _canalId = 'hora_da_ave_maria';
  static const _canalNome = 'Hora da Ave-Maria';

  Future<void> _iniciar() async {
    if (_iniciado) return;
    tz.initializeTimeZones(); // <-- Inicializa a base de fusos
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(), // <-- Suporte ao iOS
      ),
    );
    _iniciado = true;
  }

  @override
  Future<bool> pedirPermissao() async {
    await _iniciar();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    // Pede autorização no iOS:
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return true;
  }

  @override
  Future<void> substituirAgenda(List<NotificacaoAgendada> notificacoes) async {
    await _iniciar();
    await _plugin.cancelAll();
    for (final n in notificacoes) {
      await _plugin.zonedSchedule(
        n.id,
        n.titulo,
        n.corpo,
        tz.TZDateTime.from(n.quando, tz.UTC),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _canalId,
            _canalNome,
            channelDescription: 'Lembretes da Hora da Ave-Maria',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(n.corpo),
          ),
          iOS: const DarwinNotificationDetails( // <-- Detalhes de som e alerta no iOS
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}