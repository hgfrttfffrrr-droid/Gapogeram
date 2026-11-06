import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/backend.dart';
import 'core/constants.dart';
import 'core/services.dart';
import 'core/storage.dart';
import 'screens/chat.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  Prefs.I.load();
  await Notif.init((payload) async {
    // 0.4 — باز کردن کانال روی همان پیام
    if (payload != null) runApp(const GapromApp(home: 'channel', focus: payload));
  });
  Conn.I.start();
  runApp(const GapromApp());
}

class GapromApp extends StatelessWidget {
  final String? home; final String? focus;
  const GapromApp({super.key, this.home, this.focus});
  @override Widget build(BuildContext c) => ListenableBuilder(listenable: Prefs.I, builder: (_, __) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'گپروم',
    theme: ThemeData(fontFamily: 'Vazirmatn', brightness: Prefs.I.dark ? Brightness.dark : Brightness.light,
      splashFactory: NoSplash.splashFactory, highlightColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()})),
    home: _Root(home: home, focus: focus)));
}

class _Root extends StatefulWidget {
  final String? home; final String? focus; const _Root({this.home, this.focus, super.key});
  @override State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  @override void initState() { super.initState(); _bootstrap(); }

  Future<void> _bootstrap() async {
    final verified = Storage.users().any((u) => u.verified);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    if (widget.home == 'channel') { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatPage(chat: 'channel'))); return; }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => verified ? const MainScreen() : const Onboarding()));
  }

  @override Widget build(BuildContext c) => Scaffold(backgroundColor: C.darkBg, body: const Center(child: CircularProgressIndicator(color: C.green, strokeWidth: 2)));
}
