import 'package:flutter/material.dart';
import '../core/backend.dart';
import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/services.dart';
import '../widgets/common.dart';
import '../widgets/keypad.dart';
import 'language.dart';
import 'otp.dart';

class Login extends StatefulWidget { const Login({super.key}); @override State<Login> createState() => _LoginState(); }

class _LoginState extends State<Login> {
  String digits = '';
  final FocusNode _fn = FocusNode();

  void add(String d) { if (digits.length < 10) setState(() => digits += d); }
  void del() { if (digits.isNotEmpty) setState(() => digits = digits.substring(0, digits.length - 1)); }

  String get masked { // --- --- ---- با جای خالی
    final s = digits.padRight(10, ' ');
    return '${s.substring(0, 3)} ${s.substring(3, 6)} ${s.substring(6, 10)}';
  }

  Future<void> submit() async {
    if (digits.length != 10 || !Conn.I.online) return;
    Navigator.push(c2(), MaterialPageRoute(builder: (_) => OtpScreen(phone: digits)));
  }
  BuildContext c2() => context;

  @override Widget build(BuildContext c) {
    final dark = Prefs.I.dark; final online = Conn.I.online;
    _applyBars(dark);
    return AnimatedContainer(duration: const Duration(milliseconds: 320), color: dark ? C.darkBg : Colors.white, child: Scaffold(backgroundColor: Colors.transparent,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 0), child: Row(children: [
          Pressable(onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const LanguageScreen())), child: Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: dark ? const Color(0xFF3a3f47) : const Color(0xFFd4d8dd), width: 1.1), ), child: const Icon(Icons.translate_outlined, size: 18, color: Color(0xFF9aa4b2), weight: 300))),
        ])),
        const Spacer(flex: 1),
        ClipOval(child: Image.asset('assets/logo.png', width: 84, height: 84, errorBuilder: (_, __, ___) => Container(width: 84, height: 84, color: C.green, child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 40)))),
        const SizedBox(height: 18),
        Text(tr('enter_phone'), style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: dark ? Colors.white : const Color(0xFF101418))),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text(tr('enter_phone_sub'), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, height: 1.8, color: dark ? const Color(0xFF8b9199) : const Color(0xFF6f7a83)))),
        const SizedBox(height: 22),
        // کارت ورودی
        Directionality(textDirection: TextDirection.ltr, child: Container(margin: const EdgeInsets.symmetric(horizontal: 34), height: 52,
          decoration: BoxDecoration(color: dark ? const Color(0xFF17171a) : const Color(0xFFf6f7f9), borderRadius: BorderRadius.circular(14), border: Border.all(color: dark ? const Color(0xFF2c2c30) : const Color(0xFFe1e4e8), width: 1)),
          child: Row(children: [
            const SizedBox(width: 12), const Text('🇮🇷', style: TextStyle(fontSize: 18)),
            const Icon(Icons.expand_more, size: 15, color: Color(0xFF8b9199)),
            Container(width: 1, height: 26, color: dark ? const Color(0xFF333338) : const Color(0xFFdcdfe3)),
            const SizedBox(width: 10),
            Text('+۹۸', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: dark ? Colors.white70 : const Color(0xFF3a3f47))),
            const SizedBox(width: 10),
            Expanded(child: Stack(children: [
              Center(child: Text(masked.replaceAll(' ', '  '), style: TextStyle(fontSize: 16, letterSpacing: 1.5, color: digits.isEmpty ? const Color(0xFF565b63) : (dark ? Colors.white : const Color(0xFF101418))))),
              if (digits.length < 10) Positioned(right: null, left: _caretLeft(), top: 0, bottom: 0, child: const _Caret()),
            ])),
            const SizedBox(width: 10),
          ]))),
        const SizedBox(height: 18),
        Keypad(onDigit: add, onDelete: del),
        const SizedBox(height: 14),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 34), child: Pressable(onTap: submit, enabled: digits.length == 10 && online, child: AnimatedContainer(duration: const Duration(milliseconds: 250), height: 46,
          decoration: BoxDecoration(color: digits.length == 10 && online ? C.green : (dark ? const Color(0xFF232326) : const Color(0xFFe4e6ea)), borderRadius: BorderRadius.circular(13),
            boxShadow: digits.length == 10 && online ? [BoxShadow(color: C.green.withOpacity(0.4), blurRadius: 16)] : []),
          alignment: Alignment.center,
          child: !online ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [ConnectingText(style: TextStyle(color: Colors.white70, fontSize: 13.5))]) : Text(tr('go'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: digits.length == 10 ? Colors.white : const Color(0xFF8b9199)))))),
        const SizedBox(height: 12),
        RichText(textDirection: TextDirection.rtl, text: TextSpan(style: TextStyle(fontSize: 10.5, color: dark ? const Color(0xFF8b9199) : const Color(0xFF6f7a83)), children: [
          const TextSpan(text: 'با ادامه، '), TextSpan(text: tr('privacy'), style: const TextStyle(color: C.green)), const TextSpan(text: ' و '), TextSpan(text: tr('rules'), style: const TextStyle(color: C.green)), const TextSpan(text: ' را می‌پذیرید.')]))),
        const Spacer(flex: 2),
      ]))));
  }

  double _caretLeft() { final pos = digits.length; final cell = 22.0; return (10 - pos) * cell; }
  void _applyBars(bool dark) => SystemChromeStyle.apply(dark: dark, green: false);
}

/// caret سبز چشمک‌زن
class _Caret extends StatefulWidget { const _Caret({super.key}); @override State<_Caret> createState() => _CaretState(); }
class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 530))..repeat(reverse: true);
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext c) => FadeTransition(opacity: _c, child: Container(width: 2.2, height: 24, color: C.green, margin: const EdgeInsets.only(top: 14)));
}

/// استایل نوار وضعیت/ناوبری سراسری (0.1)
class SystemChromeStyle {
  static void apply({required bool dark, bool green = false, bool lightNav = false}) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: green ? C.green : (dark ? C.darkBg : Colors.white),
      statusBarIconBrightness: (green || dark) ? Brightness.light : Brightness.dark,
      statusBarBrightness: (green || dark) ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: green || lightNav ? C.lightNav : (dark ? Colors.black : const Color(0xFFececec)),
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }
}
