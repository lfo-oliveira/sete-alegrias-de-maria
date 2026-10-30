import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:sete_alegrias_de_maria/features/lembretes/domain/agenda.dart';

/// Quem agenda as notificações no celular.
/// É uma interface para que os testes usem uma versão falsa.
abstract class AgendadorLembretes {
  /// Pede permissão de notificação. Devolve true se o fiel permitiu.
  Future<bool> pedirPermissao();

  /// Só confere se as notificações estão permitidas, sem perguntar nada.
  Future<bool> permissaoConcedida();

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
    await _plugin.initialize(
      const InitializationSettings(
        // Ícone branco e transparente (android/app/src/main/res/drawable):
        // o ícone colorido do app vira um quadrado branco na barra de status.
        android: AndroidInitializationSettings('ic_notificacao'),
      ),
    );
    _iniciado = true;
  }

  @override
  Future<bool> pedirPermissao() async {
    await _iniciar();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    return await android.requestNotificationsPermission() ?? false;
  }

  @override
  Future<bool> permissaoConcedida() async {
    await _iniciar();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    return await android.areNotificationsEnabled() ?? false;
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
        // O instante é o que importa: o horário local vira UTC com o mesmo
        // momento exato, então não depende de descobrir o fuso do aparelho.
        tz.TZDateTime.from(n.quando, tz.UTC),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _canalId,
            _canalNome,
            channelDescription: 'Lembretes da Hora da Ave-Maria',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF6B4A2F), // marrom do tema
            styleInformation: BigTextStyleInformation(n.corpo),
          ),
        ),
        // Aproximado: não exige a permissão de "alarme exato" e basta para
        // um lembrete de oração (pode atrasar alguns minutos).
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
