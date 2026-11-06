import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class User {
  String phone, first, last; String? avatarPath; bool verified; int joined;
  User({required this.phone, required this.first, this.last = '', this.avatarPath, this.verified = false, required this.joined});
  Map<String, dynamic> toJson() => {'phone': phone, 'first': first, 'last': last, 'avatar': avatarPath, 'verified': verified, 'joined': joined};
  User.fromJson(Map j) : phone = j['phone'], first = j['first'], last = j['last'] ?? '', avatarPath = j['avatar'], verified = j['verified'] ?? false, joined = j['joined'] ?? 0;
  String get name => '$first $last'.trim();
}

class Msg {
  String id, chat, sender, text; int ts; List<String> views; bool pinned, edited; String? replyTo, replyName, replyText;
  Msg({required this.id, required this.chat, required this.sender, required this.text, required this.ts,
       List<String>? views, this.pinned = false, this.edited = false, this.replyTo, this.replyName, this.replyText});
  Map<String, dynamic> toJson() => {'id': id,'chat': chat,'sender': sender,'text': text,'ts': ts,'views': views,'pinned': pinned,'edited': edited,'replyTo': replyTo,'replyName': replyName,'replyText': replyText};
  Msg.fromJson(Map j) : id=j['id'], chat=j['chat'], sender=j['sender'], text=j['text'], ts=j['ts'],
      views=List<String>.from(j['views'] ?? []), pinned=j['pinned'] ?? false, edited=j['edited'] ?? false,
      replyTo=j['replyTo'], replyName=j['replyName'], replyText=j['replyText'];
}

/// لایه ذخیره‌سازی ماندگار (فایل JSON + SharedPreferences برای کلیدهای کوچک)
class Storage {
  static late Directory _dir;
  static Map<String, dynamic> db = {};
  static Future<void> init() async {
    _dir = await getApplicationDocumentsDirectory();
    final f = File('${_dir.path}/gaprom_db.json');
    if (await f.exists()) { try { db = jsonDecode(await f.readAsString()); } catch (_) {} }
    db.putIfAbsent('users', () => <dynamic>[]);
    db.putIfAbsent('posts', () => <dynamic>[]);      // کانال
    db.putIfAbsent('saved', () => <dynamic>[]);      // همه چت‌های ذخیره‌شده
    db.putIfAbsent('lastRead', () => {});
    db.putIfAbsent('otpLog', () => {});
    db.putIfAbsent('queue', () => <dynamic>[]);
    db.putIfAbsent('recents', () => <dynamic>[]);
    db.putIfAbsent('mute', () => {});
    await _save();
  }
  static Future<void> _save() async => await File('${_dir.path}/gaprom_db.json').writeAsString(jsonEncode(db));
  static Future<void> save() => _save();
  static String get dir => _dir.path;

  // کاربران
  static List<User> users() => (db['users'] as List).map((e) => User.fromJson(e)).toList();
  static User? user(String phone) { final p = phone.replaceAll(RegExp(r'\D'), '');
    for (final u in users()) if (u.phone.replaceAll(RegExp(r'\D'), '') == p) return u; return null; }
  static Future<void> upsertUser(User u) async {
    final l = db['users'] as List; l.removeWhere((e) => e['phone'] == u.phone); l.add(u.toJson()); await _save();
  }

  // پیام‌ها
  static List<Msg> msgs(String chat) => ((db[chat == 'channel' ? 'posts' : 'saved'] as List))
      .map((e) => Msg.fromJson(e)).toList()..sort((a, b) => a.ts.compareTo(b.ts));
  static Future<void> putMsg(Msg m) async {
    final key = m.chat == 'channel' ? 'posts' : 'saved'; final l = db[key] as List;
    final i = l.indexWhere((e) => e['id'] == m.id);
    if (i >= 0) l[i] = m.toJson(); else l.add(m.toJson()); await _save();
  }
  static Future<void> delMsg(String chat, String id) async {
    final key = chat == 'channel' ? 'posts' : 'saved'; (db[key] as List).removeWhere((e) => e['id'] == id); await _save();
  }

  // آخرین بازدید / موضوعات کوچک
  static int lastRead(String phone, String chat) => (db['lastRead'] as Map)['$phone:$chat'] ?? 0;
  static Future<void> setLastRead(String phone, String chat) async { (db['lastRead'] as Map)['$phone:$chat'] = DateTime.now().millisecondsSinceEpoch; await _save(); }
  static List<String> recents() => List<String>.from(db['recents']);
  static Future<void> setRecents(List<String> r) async { db['recents'] = r; await _save(); }
  static bool mute(String phone) => (db['mute'] as Map)[phone] ?? false;
  static Future<void> setMute(String phone, bool v) async { (db['mute'] as Map)[phone] = v; await _save(); }

  // صف آفلاین
  static List<Map<String, dynamic>> queue() => List<Map<String, dynamic>>.from(db['queue']);
  static Future<void> enqueue(Map<String, dynamic> m) async { (db['queue'] as List).add(m); await _save(); }
  static Future<void> dequeue(String id) async { (db['queue'] as List).removeWhere((e) => e['id'] == id); await _save(); }

  // محدودیت OTP: حداکثر ۲ درخواست در ۴۸ ساعت غلتان
  static List<int> otpTimes(String phone) => List<int>.from((db['otpLog'] as Map)[phone] ?? []);
  static Future<bool> otpAllowed(String phone) async {
    final now = DateTime.now().millisecondsSinceEpoch; final cut = now - 48 * 3600 * 1000;
    final l = otpTimes(phone).where((t) => t > cut).toList();
    (db['otpLog'] as Map)[phone] = l; await _save();
    return l.length < 2;
  }
  static Future<void> otpUsed(String phone) async {
    final l = otpTimes(phone)..add(DateTime.now().millisecondsSinceEpoch);
    (db['otpLog'] as Map)[phone] = l; await _save();
  }

  // تم / زبان / وضعیت‌ها
  static Future<void> set(String k, dynamic v) async { db[k] = v; await _save(); }
  static dynamic get(String k, [dynamic d]) => db[k] ?? d;
}
