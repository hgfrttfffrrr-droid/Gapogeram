import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'storage.dart';

/// لایه شبکه: حالت سرور دور (همگام‌سازی چندنفره) یا حالت محلی
class Backend {
  static bool get remote => C.serverBase.isNotEmpty;

  static Future<bool> ping() async {
    try {
      if (remote) { final r = await http.get(Uri.parse('${C.serverBase}/ping')).timeout(const Duration(milliseconds: 1500)); return r.statusCode == 200; }
      final r = await InternetAddress.lookup('example.com').timeout(const Duration(milliseconds: 1500));
      return r.isNotEmpty && r[0].rawAddress.isNotEmpty;
    } catch (_) { return false; }
  }

  // ----- OTP واقعی MeliPayamak -----
  static Future<String?> sendOtp(String phone10) async {
    try {
      final r = await http.post(Uri.parse(C.otpUrl),
          headers: {'Content-Type': 'application/json', 'x-api-key': C.otpKey},
          body: jsonEncode({'to': '+98$phone10'})).timeout(const Duration(seconds: 20));
      if (r.statusCode == 200) { final j = jsonDecode(r.body); return j['code']?.toString(); }
    } catch (_) {}
    return null;
  }

  // ----- کانال -----
  static List<Msg> channelPosts() => Storage.msgs('channel');
  static Future<void> publish(Msg m) async {
    await Storage.putMsg(m);
    if (remote) { try { await http.post(Uri.parse('${C.serverBase}/posts'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(m.toJson())); } catch (_) {} }
  }
  static Future<void> syncChannel() async {
    if (!remote) return;
    try {
      final r = await http.get(Uri.parse('${C.serverBase}/posts'));
      if (r.statusCode == 200) {
        final list = (jsonDecode(r.body) as List).map((e) => Msg.fromJson(e)).toList();
        for (final m in list) await Storage.putMsg(m);
      }
    } catch (_) {}
  }
  static Future<void> update(Msg m) async {
    await Storage.putMsg(m);
    if (remote) { try { await http.post(Uri.parse('${C.serverBase}/posts/update'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(m.toJson())); } catch (_) {} }
  }
  static Future<void> remove(String chat, String id) async {
    await Storage.delMsg(chat, id);
    if (remote && chat == 'channel') { try { await http.post(Uri.parse('${C.serverBase}/posts/delete'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'id': id})); } catch (_) {} }
  }
  static Future<void> addView(Msg m, String phone) async {
    if (m.views.contains(phone)) return;
    m.views.add(phone); await Storage.putMsg(m);
    if (remote) { try { await http.post(Uri.parse('${C.serverBase}/posts/view'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'id': m.id, 'phone': phone})); } catch (_) {} }
  }
  static Future<int> memberCount() async {
    if (remote) { try { final r = await http.get(Uri.parse('${C.serverBase}/members')); if (r.statusCode == 200) return int.tryParse(r.body) ?? 1; } catch (_) {} return 1; }
    return Storage.users().where((u) => u.verified).length;
  }
  static Future<void> registerUser(User u, {String? fcmToken}) async {
    await Storage.upsertUser(u);
    if (remote) { try { await http.post(Uri.parse('${C.serverBase}/users'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({...u.toJson(), 'fcm': fcmToken})); } catch (_) {} }
  }
}
