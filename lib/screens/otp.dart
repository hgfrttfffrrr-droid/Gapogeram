import 'dart:async';
import 'package:flutter/material.dart';
import '../core/backend.dart';
import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/services.dart';
import '../core/storage.dart';
import '../widgets/common.dart';
import '../widgets/keypad.dart';
import 'language.dart';
import 'profile.dart';

class OtpScreen extends StatefulWidget {
  final String phone; const OtpScreen({super.key, required this.phone});
  @override State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String code = ''; String? expected; Timer? _timer; int left = 120; bool sending = false; bool wrong = false; bool ok = false;

  @override void initState() { super.initState(); _request(); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _request() async {
    setState(() { sending = true; left = 120; });
    final allowed = C.isOwner(widget.phone) || await Storage.otpAllowed(widget.phone);
    if (allowed) { expected = await Backend.sendOtp(widget.phone); await Storage.otpUsed(widget.phone); }
    setState(() => sending = false);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) { if (left > 0) setState(() => left--); else t.cancel(); });
  }

  void _add(String d) {
    if (code.length >= 6) return;
    setState(() => code += d);
    if (code.length == 6) _validate();
  }
  void _del() => setState(() => code = code.isEmpty ? code : code.substring(0, code.length - 1));

  Future<void> _validate() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (code == expected) {
      setState(() => ok = true);
      await Future.delayed(const Duration(milliseconds: 450));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen(phone: widget.phone)));
    } else {
      setState(() => wrong = true);
      await Future.delayed(const Duration(milliseconds: 2000));
      setState(() { wrong = false; code = ''; });
    }
  }

  String _mmss() => '${left ~/ 60}:${(left % 60).toString().padLeft(2, '0')}';

  @override Widget build(BuildContext c) {
    final dark = Prefs.I.dark;
    SystemChromeStyle.apply(dark: dark);
    return AnimatedContainer(duration: const Duration(milliseconds: 320), color: dark ? C.darkBg : Colors.white, child: Scaffold(backgroundColor: Colors.transparent,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 0), child: Row(children: [
          Pressable(onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const LanguageScreen())), child: Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: dark ? const Color(0xFF3a3f47) : const Color(0xFFd4d8dd), width: 1.1)), child: const Icon(Icons.translate_outlined, size: 18, color: Color(0xFF9aa4b2), weight: 300))),
        ])),
        const Spacer(flex: 1),
        ClipOval(child: Image.asset('assets/logo.png', width: 76, height: 76, errorBuilder: (_, __, ___) => Container(width: 76, height: 76, color: C.green, child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 34)))),
        const SizedBox(height: 16),
        Text(tr('enter_otp'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: dark ? Colors.white : const Color(0xFF101418))),
        const SizedBox(height: 8),
        Directionality(textDirection: TextDirection.rtl, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.edit_outlined, size: 12, color: C.green),
          const SizedBox(width: 5),
          Text('${tr('otp_sub')} ', style: TextStyle(fontSize: 11.5, color: dark ? const Color(0xFF8b9199) : const Color(0xFF6f7a83))),
          Directionality(textDirection: TextDirection.ltr, child: Text('+98 ${widget.phone.substring(0, 3)} ${widget.phone.substring(3, 6)} ${widget.phone.substring(6)}', style: const TextStyle(fontSize: 11.5, color: C.green, fontWeight: FontWeight.w600))),
        ])),
        const SizedBox(height: 22),
        // ۶ جعبه
        AnimatedBuilder(animation: Listenable.merge([]), builder: (_, __) => Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(6, (i) {
          final filled = i < code.length;
          return AnimatedContainer(duration: const Duration(milliseconds: 200), key: wrong ? ValueKey('w$i${DateTime.now().millisecond}') : null,
            margin: const EdgeInsets.symmetric(horizontal: 4), width: 44, height: 48,
            decoration: BoxDecoration(
              color: wrong ? const Color(0x22e05252) : (ok ? const Color(0x2200b894) : (filled ? const Color(0x1a00b894) : (dark ? const Color(0xFF17171a) : const Color(0xFFf6f7f9)))),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: wrong ? const Color(0xFFe05252) : (filled || ok ? C.green : (dark ? const Color(0xFF2c2c30) : const Color(0xFFe1e4e8))), width: 1.2)),
            child: Center(child: Text(i < code.length ? C.faDigits[int.parse(code[i])!] : '', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: dark ? Colors.white : const Color(0xFF101418)))));
        })))),
        if (wrong) const Padding(padding: EdgeInsets.only(top: 8), child: Text('کد نادرست است', style: TextStyle(fontSize: 11, color: Color(0xFFe05252)))),
        const SizedBox(height: 16),
        left > 0
          ? Directionality(textDirection: TextDirection.rtl, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${tr('resend_in')} ', style: TextStyle(fontSize: 11.5, color: dark ? const Color(0xFF8b9199) : const Color(0xFF6f7a83))),
              Directionality(textDirection: TextDirection.ltr, child: Text(fa(_mmss()), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: dark ? Colors.white70 : const Color(0xFF3a3f47)))),
              Text(' ${tr('resend_in2')}', style: TextStyle(fontSize: 11.5, color: dark ? const Color(0xFF8b9199) : const Color(0xFF6f7a83))),
            ]))
          : Pressable(onTap: _request, child: Text(tr('resend'), style: const TextStyle(fontSize: 12.5, color: C.green, fontWeight: FontWeight.w700))),
        const SizedBox(height: 18),
        Keypad(persian: true, onDigit: _add, onDelete: _del),
        const Spacer(flex: 2),
      ]))));
  }
}
