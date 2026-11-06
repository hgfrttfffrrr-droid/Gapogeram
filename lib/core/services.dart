import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'backend.dart';
import 'storage.dart';

/// 0.2 — پینگ هر ۲ ثانیه به بک‌اند (نه فقط فلگ سیستم‌عامل)
class Conn extends ChangeNotifier {
  static final Conn I = Conn();
  bool online = true;
  Timer? _t;
  void start() { _t?.cancel(); _t = Timer.periodic(const Duration(seconds: 2), (_) async {
    final ok = await Backend.ping(); if (ok != online) { online = ok; notifyListeners(); } }); }
  @override void dispose() { _t?.cancel(); super.dispose(); }
}

/// 0.3 — صدای ارسال
class Sound {
  static final AudioPlayer _p = AudioPlayer();
  static Future<void> send() async { try { await _p.play(AssetSource('sounds/send.mp3')); } catch (_) {} }
}

/// 0.4 — نوتیفیکیشن سیستمی
class Notif {
  static final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  static Future<void> init(void Function(String?) onTap) async {
    const and = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(const InitializationSettings(android: and), onDidReceiveNotificationResponse: (r) => onTap(r.payload));
    try { await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission(); } catch (_) {}
  }
  static Future<void> post(String title, String body, String payload) => plugin.show(
      title.hashCode & 0x7fffffff, title, body,
      const NotificationDetails(android: AndroidNotificationDetails('gaprom', 'گپروم', importance: Importance.high, priority: Priority.high)),
      payload: payload);
}

/// تم و زبان ماندگار
class Prefs extends ChangeNotifier {
  static final Prefs I = Prefs();
  bool dark = true; String lang = 'fa';
  void load() { dark = Storage.get('theme', 'dark') == 'dark'; lang = Storage.get('lang', 'fa'); }
  Future<void> setDark(bool v) async { dark = v; await Storage.set('theme', v ? 'dark' : 'light'); notifyListeners(); }
  Future<void> setLang(String v) async { lang = v; await Storage.set('lang', v); notifyListeners(); }
}
