import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/legal_case.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleReminders(LegalCase legalCase, {int dayBeforeHour = 9, int dayOfHour = 8}) async {
    await cancelReminders(legalCase.id);

    final now = tz.TZDateTime.now(tz.local);

    // T-1 day reminder
    final dayBefore = tz.TZDateTime(
      tz.local,
      legalCase.caseDate.year,
      legalCase.caseDate.month,
      legalCase.caseDate.day - 1,
      dayBeforeHour,
      0,
    );

    if (dayBefore.isAfter(now)) {
      await _notifications.zonedSchedule(
        legalCase.id.hashCode * 2,
        'Case Reminder',
        '${legalCase.caseNumber} — ${legalCase.caseName} is tomorrow.',
        dayBefore,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'case_reminders',
            'Case Reminders',
            channelDescription: 'Reminders for upcoming court cases',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // Day-of check-in
    final dayOf = tz.TZDateTime(
      tz.local,
      legalCase.caseDate.year,
      legalCase.caseDate.month,
      legalCase.caseDate.day,
      dayOfHour,
      0,
    );

    if (dayOf.isAfter(now)) {
      await _notifications.zonedSchedule(
        legalCase.id.hashCode * 2 + 1,
        'Case Check-In',
        'Did ${legalCase.caseNumber} — ${legalCase.caseName} happen today?',
        dayOf,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'case_checkin',
            'Case Check-In',
            channelDescription: 'Day-of check-in for court cases',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelReminders(String caseId) async {
    await _notifications.cancel(caseId.hashCode * 2);
    await _notifications.cancel(caseId.hashCode * 2 + 1);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}
