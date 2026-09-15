import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/couple_date.dart';
import '../data/love_messages.dart';
import 'app_state.dart';

/// Notificações: mensagem de amor do dia (sincronizada com o card) + véspera
/// das datas importantes. Agenda dias individuais e reagenda na abertura —
/// nada de texto "congelado" que repete.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    _ready = true;
  }

  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return (await android?.requestNotificationsPermission()) ?? true;
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  /// Conveniência: reagenda tudo a partir do estado atual (pede permissão).
  Future<void> reschedule(AppState s) async {
    await requestPermission();
    await scheduleAll(
      reminderOn: s.reminderOn,
      hour: s.reminderHour,
      minute: s.reminderMin,
      coupleLabel: s.coupleLabel,
      dates: s.dates,
      anniversary: s.startDate,
      lang: s.lang,
    );
  }

  static String _tr(String lang, String pt, String en, String es) =>
      lang == 'pt' ? pt : (lang == 'es' ? es : en);

  /// (Re)agenda tudo: mensagem do dia (14 dias) + véspera das datas.
  Future<void> scheduleAll({
    required bool reminderOn,
    required int hour,
    required int minute,
    required String coupleLabel,
    required List<CoupleDate> dates,
    DateTime? anniversary,
    String lang = 'pt',
  }) async {
    await init();
    await _plugin.cancelAll();
    if (!reminderOn) return;
    final now = tz.TZDateTime.now(tz.local);
    final chMsg = _tr(lang, 'Mensagem do dia', 'Message of the day',
        'Mensaje del día');
    final chDates = _tr(lang, 'Datas', 'Dates', 'Fechas');

    // Mensagem de amor do dia — próximos 14 dias.
    for (var d = 0; d < 14; d++) {
      final date = DateTime.now().add(Duration(days: d));
      final when = tz.TZDateTime(
          tz.local, date.year, date.month, date.day, hour, minute);
      if (when.isBefore(now)) continue;
      await _schedule(1000 + d, '💞 $coupleLabel',
          LoveMessages.ofDay(lang, date), when, 'amor_diario', chMsg);
    }

    // Datas comemorativas (aniversário de namoro + datas do usuário):
    // agenda a PRÓXIMA ocorrência de cada uma — véspera (18h) e no dia (hora do
    // aviso). Cobre o ano todo, e reagenda a cada abertura / ao add/remover data.
    final anivName = _tr(lang, 'Aniversário de namoro',
        'Relationship anniversary', 'Aniversario de novios');
    final all = <CoupleDate>[
      if (anniversary != null)
        CoupleDate('aniv', anivName, anniversary, emoji: '💞'),
      ...dates,
    ];
    var id = 2000;
    for (final ev in all) {
      final until = ev.daysUntilNext(); // 0..364 (próxima ocorrência)
      final target = DateTime.now().add(Duration(days: until));

      // No dia, na hora do aviso.
      final dayOf = tz.TZDateTime(
          tz.local, target.year, target.month, target.day, hour, minute);
      if (dayOf.isAfter(now)) {
        final title = _tr(lang, '${ev.emoji} Hoje: ${ev.name}!',
            '${ev.emoji} Today: ${ev.name}!', '${ev.emoji} Hoy: ${ev.name}!');
        final body = _tr(lang, 'É hoje a data especial de vocês 💕',
            "It's your special date today 💕",
            'Hoy es su fecha especial 💕');
        await _schedule(id++, title, body, dayOf, 'datas', chDates);
      }

      // Véspera às 18h.
      final eve = tz.TZDateTime(
          tz.local, target.year, target.month, target.day, 18, 0)
          .subtract(const Duration(days: 1));
      if (eve.isAfter(now)) {
        final title = _tr(lang, 'Amanhã: ${ev.name} ${ev.emoji}',
            'Tomorrow: ${ev.name} ${ev.emoji}',
            'Mañana: ${ev.name} ${ev.emoji}');
        final body = _tr(lang, 'Não esqueça da data especial de vocês 💕',
            "Don't forget your special date 💕",
            'No olviden su fecha especial 💕');
        await _schedule(id++, title, body, eve, 'datas', chDates);
      }
    }
  }

  Future<void> _schedule(int id, String title, String body,
      tz.TZDateTime when, String channel, String channelName) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
